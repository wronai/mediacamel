require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');
const { Sequelize, DataTypes } = require('sequelize');
const helmet = require('helmet');
const compression = require('compression');

// Initialize Express app
const app = express();

// Load environment variables with defaults
const PORT = process.env.PORT || 9084;
const HOST = process.env.HOST || '0.0.0.0';
const API_BASE_PATH = process.env.API_BASE_PATH || '/api';
const NODE_ENV = process.env.NODE_ENV || 'development';
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

// Configure logging
const logger = {
  info: (...args) => console.log('[INFO]', ...args),
  error: (...args) => console.error('[ERROR]', ...args),
  debug: (...args) => LOG_LEVEL === 'debug' && console.debug('[DEBUG]', ...args)
};

// Initialize database connection
let sequelize;
try {
  sequelize = new Sequelize({
    dialect: 'postgres',
    host: process.env.DB_HOST || 'medavault-db',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'medavault',
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    logging: LOG_LEVEL === 'debug' ? logger.debug : false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  });
  
  // Test the database connection
  (async () => {
    try {
      await sequelize.authenticate();
      logger.info('Database connection has been established successfully.');
    } catch (error) {
      logger.error('Unable to connect to the database:', error);
      process.exit(1);
    }
  })();
} catch (error) {
  logger.error('Failed to initialize database connection:', error);
  process.exit(1);
}

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
app.use((req, res, next) => {
  logger.debug(`${req.method} ${req.originalUrl}`);
  next();
});

// Define database models
const User = sequelize.define('User', {
  username: { type: DataTypes.STRING, allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false },
  role: { 
    type: DataTypes.ENUM('administrator', 'manager', 'external_client'),
    defaultValue: 'external_client'
  },
  email: { type: DataTypes.STRING, allowNull: true, validate: { isEmail: true } },
  isActive: { type: DataTypes.BOOLEAN, defaultValue: true }
});

const Media = sequelize.define('Media', {
  id: { type: DataTypes.UUID, primaryKey: true, defaultValue: DataTypes.UUIDV4 },
  originalName: { type: DataTypes.STRING, allowNull: false },
  fileName: { type: DataTypes.STRING, allowNull: false },
  fileType: { type: DataTypes.STRING, allowNull: false },
  fileSize: { type: DataTypes.INTEGER, allowNull: false },
  filePath: { type: DataTypes.STRING, allowNull: false },
  thumbnailPath: { type: DataTypes.STRING },
  metadata: { type: DataTypes.JSONB, defaultValue: {}},
  description: { type: DataTypes.TEXT },
  tags: { type: DataTypes.ARRAY(DataTypes.STRING), defaultValue: [] },
  isPublic: { type: DataTypes.BOOLEAN, defaultValue: false },
  uploadedBy: { type: DataTypes.INTEGER, references: { model: 'Users', key: 'id' } }
});

// Initialize database tables
const initDatabase = async () => {
  try {
    await sequelize.sync({ alter: true });
    logger.info('Database synchronized');
    
    // Create default admin user if not exists
    const adminUser = await User.findOne({ where: { username: 'admin' } });
    if (!adminUser) {
      const bcrypt = require('bcryptjs');
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await User.create({
        username: 'admin',
        password: hashedPassword,
        role: 'administrator',
        email: 'admin@example.com',
        isActive: true
      });
      logger.info('Default admin user created');
    }
  } catch (error) {
    logger.error('Failed to initialize database:', error);
    process.exit(1);
  }
};

// Call the initialization function
initDatabase();

// Ensure directories exist
const ensureDir = (dir) => {
  try {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true, mode: 0o755 });
      logger.debug(`Created directory: ${dir}`);
    }
  } catch (error) {
    logger.error(`Failed to create directory ${dir}:`, error);
    throw error;
  }
};

ensureDir('./processed/images');
ensureDir('./processed/videos');
ensureDir('./processed/documents');
ensureDir('./processed/thumbnails');

// Routes

// Health check
app.get(`${API_BASE_PATH}/health`, (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'MedaVault Backend'
    });
});

// Get all media
app.get(`${API_BASE_PATH}/media`, (req, res) => {
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
app.post(`${API_BASE_PATH}/media`, (req, res) => {
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
app.get(`${API_BASE_PATH}/media/:id`, (req, res) => {
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
app.get(`${API_BASE_PATH}/stats`, (req, res) => {
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

// Start the server
const server = app.listen(PORT, HOST, () => {
    console.log(`🚀 Server is running on http://${HOST}:${PORT}${API_BASE_PATH}`);
    console.log(`📊 Health check: http://${HOST}:${PORT}${API_BASE_PATH}/health`);
    console.log(`📁 Media API: http://${HOST}:${PORT}${API_BASE_PATH}/media`);
});

// Handle server errors
server.on('error', (error) => {
    console.error('❌ Server error:', error);
    process.exit(1);
});
