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
});

// Upload/Process media from Camel
app.post(`${API_BASE_PATH}/media`, upload.single('file'), async (req, res) => {
  try {
    const mediaId = uuidv4();
    const mediaRecord = {
      id: mediaId,
      originalName: req.file.originalname,
      fileName: req.file.filename,
      fileType: req.file.mimetype.split('/')[0],
      fileSize: req.file.size,
      filePath: req.file.path,
      thumbnailPath: null,
      metadata: {
        width: null,
        height: null,
        duration: null
      },
      description: req.body.description,
      tags: req.body.tags,
      isPublic: req.body.isPublic,
      uploadedBy: req.user.id
    };

    // Generate thumbnail for images
    if (req.file.mimetype.startsWith('image') && req.file.path) {
      const thumbnailPath = await generateThumbnail(req.file.path, mediaId);
      mediaRecord.thumbnailPath = thumbnailPath;
    }

    await Media.create(mediaRecord);

    res.json({
      success: true,
      message: 'Media processed successfully',
      mediaId: mediaId,
      media: mediaRecord
    });
  } catch (error) {
    logger.error('Error processing media:', error);
    res.status(500).json({
      success: false,
      message: 'Error processing media',
      error: error.message
    });
  }
});

// Get all media with pagination and filtering
app.get(`${API_BASE_PATH}/media`, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 50, 100); // Max 100 items per page
    const offset = (page - 1) * limit;
    
    // Build where clause based on query parameters
    const where = {};
    
    // Filter by file type
    if (req.query.type) {
      where.fileType = req.query.type;
    }
    
    // Filter by tag
    if (req.query.tag) {
      where.tags = {
        [Sequelize.Op.contains]: [req.query.tag]
      };
    }
    
    // Filter by date range
    if (req.query.startDate || req.query.endDate) {
      where.createdAt = {};
      if (req.query.startDate) {
        where.createdAt[Sequelize.Op.gte] = new Date(req.query.startDate);
      }
      if (req.query.endDate) {
        where.createdAt[Sequelize.Op.lte] = new Date(req.query.endDate);
      }
    }
    
    // Get total count for pagination
    const total = await Media.count({ where });
    
    // Get paginated results
    const media = await Media.findAll({
      where,
      limit,
      offset,
      order: [['createdAt', 'DESC']],
      attributes: [
        'id',
        'originalName',
        'fileName',
        'fileType',
        'fileSize',
        'filePath',
        'thumbnailPath',
        'createdAt',
        'updatedAt',
        'metadata',
        'description',
        'tags',
        'isPublic'
      ]
    });
    
    // Format response
    const response = {
      success: true,
      data: media.map(item => ({
        id: item.id,
        originalName: item.originalName,
        fileType: item.fileType,
        fileSize: item.fileSize,
        fileUrl: `/api/media/${item.id}/file`,
        thumbnailUrl: item.thumbnailPath ? `/api/media/${item.id}/thumbnail` : null,
        uploadDate: item.createdAt,
        metadata: item.metadata,
        description: item.description,
        tags: item.tags,
        isPublic: item.isPublic
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };
    
    res.json(response);
  } catch (error) {
    logger.error('Error fetching media:', error);
    res.status(500).json({ 
      success: false,
      error: 'Error fetching media',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get media by ID
app.get(`${API_BASE_PATH}/media/:id`, async (req, res) => {
  try {
    const media = await Media.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'uploader',
          attributes: ['id', 'username', 'email']
        }
      ]
    });
    
    if (!media) {
      return res.status(404).json({ 
        success: false,
        error: 'Media not found' 
      });
    }
    
    // Check if user has permission to view this media
    if (!media.isPublic && (!req.user || req.user.id !== media.uploadedBy)) {
      return res.status(403).json({
        success: false,
        error: 'You do not have permission to view this media'
      });
    }
    
    res.json({
      success: true,
      data: {
        id: media.id,
        originalName: media.originalName,
        fileType: media.fileType,
        fileSize: media.fileSize,
        fileUrl: `/api/media/${media.id}/file`,
        thumbnailUrl: media.thumbnailPath ? `/api/media/${media.id}/thumbnail` : null,
        uploadDate: media.createdAt,
        metadata: media.metadata,
        description: media.description,
        tags: media.tags,
        isPublic: media.isPublic,
        uploader: media.uploader ? {
          id: media.uploader.id,
          username: media.uploader.username,
          email: media.uploader.email
        } : null
      }
    });
  } catch (error) {
    logger.error('Error fetching media:', error);
    res.status(500).json({ 
      success: false,
      error: 'Error fetching media',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Download media file
app.get(`${API_BASE_PATH}/media/:id/download`, async (req, res) => {
  try {
    const media = await Media.findByPk(req.params.id);
    
    if (!media) {
      return res.status(404).json({
        success: false,
        error: 'Media not found'
      });
    }
    
    // Check permissions
    if (!media.isPublic && (!req.user || req.user.id !== media.uploadedBy)) {
      return res.status(403).json({
        success: false,
        error: 'You do not have permission to download this media'
      });
    }
    
    const filePath = path.join(__dirname, '..', 'storage', media.filePath);
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        error: 'File not found on server'
      });
    }
    
    // Set headers for file download
    res.setHeader('Content-Type', media.metadata?.mimetype || 'application/octet-stream');
    res.setHeader('Content-Length', media.fileSize);
    res.setHeader('Content-Disposition', `attachment; filename="${media.originalName}"`);
    
    // Stream the file
    const stream = fs.createReadStream(filePath);
    stream.on('error', (error) => {
      logger.error('Error streaming file for download:', error);
      if (!res.headersSent) {
        res.status(500).json({
          success: false,
          error: 'Error streaming file for download'
        });
      }
    });
    
    stream.pipe(res);
  } catch (error) {
    logger.error('Error downloading media:', error);
    res.status(500).json({
      success: false,
      error: 'Error downloading media',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});
            message: 'Media file not found'
        });
    }

    if (fs.existsSync(media.processedPath)) {
        res.download(media.processedPath, media.filename);
    } else {
        res.status(404).json({
            success: false,

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Server error:', {
    message: error.message,
    stack: error.stack,
    url: req.originalUrl,
    method: req.method,
    params: req.params,
    query: req.query,
    body: req.body
  });
  
  // Handle specific error types
  if (error.name === 'SequelizeValidationError' || error.name === 'SequelizeUniqueConstraintError') {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      details: error.errors.map(e => ({
        field: e.path,
        message: e.message
      }))
    });
  }
  
  if (error.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      error: 'Invalid token',
      details: 'The provided authentication token is invalid or has expired'
    });
  }
  
  if (error.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      error: 'File too large',
      details: 'The uploaded file exceeds the maximum allowed size'
    });
  }
  
  // Default error response
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'An unexpected error occurred',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// 404 handler - Single consolidated handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Not found',
    message: `The requested resource ${req.originalUrl} was not found on this server`,
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  });
});

/**
 * Graceful shutdown handler
 * Handles cleanup of resources when the server is shutting down
 */
const gracefulShutdown = async () => {
  logger.info('🛑 Shutting down server gracefully...');
  
  try {
    // Close database connection if it exists
    if (sequelize) {
      logger.info('🔌 Closing database connection...');
      await sequelize.close();
      logger.info('✅ Database connection closed');
    }
    
    // Close the HTTP server if it exists
    if (server) {
      logger.info('🛑 Closing HTTP server...');
      
      // Close all connections
      server.close(() => {
        logger.info('✅ HTTP server closed');
        process.exit(0);
      });
      
      // Force close after timeout if needed
      const forceShutdown = setTimeout(() => {
        logger.warn('⚠️ Forcing server to stop after timeout');
        process.exit(1);
      }, 10000);
      
      // Prevent hanging on force shutdown
      forceShutdown.unref();
    } else {
      process.exit(0);
    }
  } catch (error) {
    logger.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
};

// Handle process termination
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Consider restarting the service in production
  if (process.env.NODE_ENV === 'production') {
    process.exit(1);
  }
});

/**
 * Start the Express server
 */
const startServer = async () => {
  try {
    // Verify database connection before starting
    if (sequelize) {
      await sequelize.authenticate();
      logger.info('✅ Database connection established');
      
      // Sync database models
      await sequelize.sync({ alter: process.env.NODE_ENV !== 'production' });
      logger.info('🔄 Database models synchronized');
    }
    
    // Start the HTTP server
    const server = app.listen(PORT, HOST, () => {
      logger.info(`🚀 Server running in ${NODE_ENV} mode`);
      logger.info(`🌐 API Base URL: http://${HOST}:${PORT}${API_BASE_PATH}`);
      logger.info(`📁 WebDAV URL: ${process.env.WEBDAV_URL || `http://${process.env.WEBDAV_HOST || 'localhost'}:${process.env.WEBDAV_PORT_HTTP || 9081}${process.env.WEBDAV_PATH || '/webdav'}`}`);
      logger.info(`🖼️  Dashboard URL: http://${process.env.DASHBOARD_HOST || 'localhost'}:${process.env.DASHBOARD_PORT || 9085}`);
      logger.info(`📊 Health check: http://${HOST}:${PORT}${API_BASE_PATH}/health`);
    });
    
    return server;
  } catch (error) {
    logger.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
const server = startServer();

// Health check endpoint
app.get(`${API_BASE_PATH}/health`, (req, res) => {
  const healthcheck = {
    status: 'UP',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: sequelize ? 'CONNECTED' : 'DISCONNECTED',
    environment: NODE_ENV,
    memoryUsage: process.memoryUsage(),
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch
  };
  
  res.status(200).json(healthcheck);
});

// Handle server errors
if (server) {
  server.on('error', (error) => {
    if (error.syscall !== 'listen') {
      throw error;
    }

    // Handle specific listen errors with friendly messages
    switch (error.code) {
      case 'EACCES':
        logger.error(`❌ Port ${PORT} requires elevated privileges`);
        process.exit(1);
        break;
      case 'EADDRINUSE':
        logger.error(`❌ Port ${PORT} is already in use`);
        process.exit(1);
        break;
      case 'EADDRNOTAVAIL':
        logger.error(`❌ Address not available: ${HOST}:${PORT}`);
        process.exit(1);
        break;
      default:
        logger.error('❌ Server error:', error);
        throw error;
    }
  });
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('⚠️ Uncaught Exception:', error);
  // Don't exit immediately, let the server continue running
  // process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('⚠️ Unhandled Rejection at:', promise, 'reason:', reason);
  // Consider restarting the service in production
  if (process.env.NODE_ENV === 'production') {
    // In production, we might want to restart the process
    // process.exit(1);
  }
});

// Handle process termination signals
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Handle process exit
process.on('exit', (code) => {
  logger.info(`Process exiting with code: ${code}`);
});

// Log unhandled promise rejections
process.on('warning', (warning) => {
  logger.warn('⚠️ Node.js warning:', warning);
});
