const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simple in-memory storage (replace with PostgreSQL in production)
let mediaStore = [];
let userStore = [
    { id: 1, username: 'admin', role: 'administrator' },
    { id: 2, username: 'manager', role: 'manager' },
    { id: 3, username: 'client', role: 'external_client' }
];

// Ensure directories exist
const ensureDir = (dir) => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
};

ensureDir('./processed/images');
ensureDir('./processed/videos');
ensureDir('./processed/documents');
ensureDir('./processed/thumbnails');

// Routes

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'MedaVault Backend'
    });
});

// Get all media
app.get('/api/media', (req, res) => {
    const { type, user, limit = 50 } = req.query;

    let filteredMedia = mediaStore;

    if (type) {
        filteredMedia = filteredMedia.filter(m => m.fileType === type);
    }

    if (user) {
        filteredMedia = filteredMedia.filter(m => m.uploadedBy === user);
    }

    const limitedMedia = filteredMedia.slice(0, parseInt(limit));

    res.json({
        success: true,
        count: limitedMedia.length,
        total: filteredMedia.length,
        media: limitedMedia
    });
});

// Upload/Process media from Camel
app.post('/api/media', (req, res) => {
    try {
        const {
            filename,
            fileType,
            processedPath,
            source,
            timestamp,
            size,
            lastModified
        } = req.body;

        const mediaId = uuidv4();
        const mediaRecord = {
            id: mediaId,
            filename: filename,
            originalName: filename,
            fileType: fileType,
            processedPath: processedPath,
            source: source || 'webdav',
            uploadedAt: timestamp || new Date().toISOString(),
            size: parseInt(size) || 0,
            lastModified: lastModified,
            status: 'processed',
            thumbnailPath: null,
            metadata: {
                width: null,
                height: null,
                duration: null
            },
            tags: [],
            uploadedBy: 'webdav-system'
        };

        // Generate thumbnail for images
        if (fileType === 'image' && processedPath) {
            generateThumbnail(processedPath, mediaId)
                .then(thumbnailPath => {
                    mediaRecord.thumbnailPath = thumbnailPath;
                    console.log(`📸 Thumbnail generated: ${thumbnailPath}`);
                })
                .catch(err => {
                    console.error(`❌ Thumbnail generation failed: ${err.message}`);
                });
        }

        mediaStore.push(mediaRecord);

        console.log(`✅ Media record created: ${filename} (${fileType})`);

        res.json({
            success: true,
            message: 'Media processed successfully',
            mediaId: mediaId,
            media: mediaRecord
        });

    } catch (error) {
        console.error('❌ Error processing media:', error);
        res.status(500).json({
            success: false,
            message: 'Error processing media',
            error: error.message
        });
    }
});

// Get specific media
app.get('/api/media/:id', (req, res) => {
    const media = mediaStore.find(m => m.id === req.params.id);

    if (!media) {
        return res.status(404).json({
            success: false,
            message: 'Media not found'
        });
    }

    res.json({
        success: true,
        media: media
    });
});

// Download media
app.get('/api/media/:id/download', (req, res) => {
    const media = mediaStore.find(m => m.id === req.params.id);

    if (!media || !media.processedPath) {
        return res.status(404).json({
            success: false,
            message: 'Media file not found'
        });
    }

    if (fs.existsSync(media.processedPath)) {
        res.download(media.processedPath, media.filename);
    } else {
        res.status(404).json({
            success: false,
            message: 'Physical file not found'
        });
    }
});

// Get thumbnail
app.get('/api/media/:id/thumbnail', (req, res) => {
    const media = mediaStore.find(m => m.id === req.params.id);

    if (!media || !media.thumbnailPath) {
        return res.status(404).json({
            success: false,
            message: 'Thumbnail not found'
        });
    }

    if (fs.existsSync(media.thumbnailPath)) {
        res.sendFile(path.resolve(media.thumbnailPath));
    } else {
        res.status(404).json({
            success: false,
            message: 'Thumbnail file not found'
        });
    }
});

// Statistics
app.get('/api/stats', (req, res) => {
    const stats = {
        totalMedia: mediaStore.length,
        mediaByType: {
            image: mediaStore.filter(m => m.fileType === 'image').length,
            video: mediaStore.filter(m => m.fileType === 'video').length,
            document: mediaStore.filter(m => m.fileType === 'document').length,
            generic: mediaStore.filter(m => m.fileType === 'generic').length
        },
        mediaBySource: {
            webdav: mediaStore.filter(m => m.source === 'webdav').length,
            upload: mediaStore.filter(m => m.source === 'upload').length
        },
        totalSize: mediaStore.reduce((sum, m) => sum + (m.size || 0), 0),
        recentUploads: mediaStore
            .sort((a, b) => new Date(b.uploadedAt) - new Date(a.uploadedAt))
            .slice(0, 10)
    };

    res.json({
        success: true,
        stats: stats
    });
});

// Users endpoint
app.get('/api/users', (req, res) => {
    res.json({
        success: true,
        users: userStore.map(u => ({ id: u.id, username: u.username, role: u.role }))
    });
});

// Helper function to generate thumbnails
async function generateThumbnail(imagePath, mediaId) {
    try {
        const thumbnailDir = './processed/thumbnails';
        ensureDir(thumbnailDir);

        const thumbnailPath = path.join(thumbnailDir, `${mediaId}_thumb.jpg`);

        await sharp(imagePath)
            .resize(300, 200, {
                fit: 'cover',
                position: 'center'
            })
            .jpeg({ quality: 80 })
            .toFile(thumbnailPath);

        return thumbnailPath;
    } catch (error) {
        console.error('Thumbnail generation error:', error);
        throw error;
    }
}

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('❌ Server error:', error);
    res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Endpoint not found'
    });
});

app.listen(PORT, () => {
    console.log(`🚀 MedaVault Backend running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`📁 Media API: http://localhost:${PORT}/api/media`);
});
