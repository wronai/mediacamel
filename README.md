# MediaCamel - Modern Media Management System

🌐 A complete, containerized media management system with WebDAV and S3 support, Apache Camel integration, and a modern web interface.

## 🌟 Features

- **Unified Storage**: Seamlessly manage files across WebDAV and S3 storage backends
- **Media Processing**: Automatic thumbnail generation and media metadata extraction
- **Multi-protocol Access**: Access files via WebDAV, S3 API, or the web interface
- **User Management**: Role-based access control for secure file sharing
- **Scalable**: Built on Docker and Kubernetes-ready architecture
- **Self-hosted**: Full control over your data and privacy
- **Extensible**: Plugin architecture for adding custom processors and integrations

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Client Applications                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Web App    │  │  Mobile App  │  │  3rd Party Clients  │  │
│  └─────┬───────┘  └──────┬──────┘  └──────────┬──────────┘  │
│        │                   │                     │              │
└────────┼───────────────────┼─────────────────────┼──────────────┘
         │                   │                     │
         ▼                   ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway (Nginx)                       │
└───────────────────────────────┬───────────────────────────────┘
                                │
                  ┌─────────────┴─────────────┐
                  │                             │
                  ▼                             ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│   WebDAV Server         │     │   Backend API           │
│  (Nginx + WebDAV)       │     │  (Node.js + Express)    │
└───────────┬─────────────┘     └───────────┬─────────────┘
            │                                 │
            │                                 │
            ▼                                 ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│   Storage Backend       │     │   Database (PostgreSQL)  │
│  • Local Filesystem     │     │   - User accounts       │
│  • S3-Compatible        │     │   - File metadata       │
│  • WebDAV Mounts        │     │   - Access controls     │
└─────────────────────────┘     └─────────────────────────┘
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![WebDAV](https://img.shields.io/badge/WebDAV-FF6D00?style=flat&logo=webdav&logoColor=white)](https://en.wikipedia.org/wiki/WebDAV)

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- Git
- At least 2GB RAM (4GB recommended)
- At least 10GB free disk space

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/mediacamel.git
   cd mediacamel
   ```

2. **Setup the environment**
   ```bash
   make setup
   ```
   This will:
   - Create a `.env` file from `.env.example` if it doesn't exist
   - Create necessary directories
   - Set up file permissions

3. **Configure (optional)**
   Edit the `.env` file to customize your setup:
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   Key settings to review:
   - `WEBDAV_USER` and `WEBDAV_PASSWORD`
   - `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` for S3 access
   - Port configurations if you need to change defaults
   - Storage paths and S3 bucket settings

4. **Build and start the services**
   ```bash
   make build
   make up
   ```

5. **Access the services**
   - **Web Interface**: http://localhost:9083
   - **MinIO Console**: http://localhost:9001 (default credentials: minioadmin/minioadmin)
   - **API Documentation**: http://localhost:9084/api-docs
   - **WebDAV Access**: http://localhost:9081/webdav

6. **Verify the installation**
   Check the logs to ensure all services are running:
   ```bash
   make logs
   ```
   ```bash
   make status
   ```
   This will show all running services and their status.

4. **Access the services**
   - Web Dashboard: http://localhost:8085
   - WebDAV Server: http://localhost:8081
   - Filestash Client: http://localhost:8082
   - API: http://localhost:8084/health

## 🛠️ Makefile Commands

```
make setup       # Setup project environment
make build      # Build all Docker containers
make up         # Start all services
make down       # Stop and remove all containers
make restart    # Restart all services
make logs       # Show logs for all services
make clean      # Remove all containers, networks, and volumes
make status     # Show service status and URLs
make test-webdav # Test WebDAV connection
make test-api   # Test API endpoints
```

## 🌟 Features

- **WebDAV Server** - Secure file storage with authentication
- **Filestash Web Client** - Modern web-based file manager
- **Media Processing** - Automatic processing of uploaded files
- **RESTful API** - Comprehensive API for media management
- **Responsive Dashboard** - Clean, modern web interface
- **Docker Support** - Easy deployment with Docker Compose

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌──────────────────┐
│   Web Users     │    │  Filestash Web   │    │   Apache Camel  │    │   MedaVault      │
│                 │───▶│     Client       │    │   Integration   │───▶│   Photo Vault    │
│  (Upload files) │    │  (WebDAV GUI)    │    │   (Processing)  │    │   (Storage)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘    └──────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   WebDAV Server  │    │   PostgreSQL    │
                       │   (nginx)        │    │   Database      │
                       │   Port: 8081     │    │   (Metadata)    │
                       └──────────────────┘    └─────────────────┘
```

## 🔌 Service Ports

| Service           | Port  | Description                     |
|-------------------|-------|---------------------------------|
| WebDAV Server     | 8081  | WebDAV file access              |
| Filestash Client  | 8082  | Web-based file manager          |
| Status Endpoint   | 8084  | WebDAV server status            |
| MedaVault Backend | 8084  | REST API and business logic     |
| Web Dashboard     | 8085  | Admin dashboard and monitoring  |


## 🛠️ Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM (minimum)
- 10GB free disk space

## 🧩 System Components

### 1. **WebDAV Server** (nginx)
- **Port**: 8081 (HTTP), 8443 (HTTPS)
- Secure WebDAV server with authentication
- File upload/download via WebDAV protocol
- Integration with Filestash and Camel
- Supports multiple concurrent connections
- Status endpoint at `:8084/status`

### 2. **Filestash Web Client**
- **Port**: 8082
- Modern web-based file manager
- Supports multiple protocols: WebDAV, S3, SFTP, Git, and more
- Drag & drop file uploads
- File previews and thumbnails
- Open source (AGPL-3.0)

### 3. **Apache Camel Integration**
- Monitors WebDAV for new files
- Processes media files (images, videos, documents)
- Generates thumbnails and extracts metadata
- Routes files to appropriate storage
- Handles error conditions and retries

### 4. **MedaVault Backend API**
- **Port**: 8084
- RESTful API for media management
- PostgreSQL database for metadata
- User authentication and authorization
- Media processing and transformation
- Search and filtering capabilities

### 5. **Web Dashboard**
- **Port**: 8085
- Real-time service monitoring
- System status overview
- Quick access to all services
- Responsive design for all devices

### 5. **Web Dashboard** - Port 8085
- System monitoring and statistics
- Media gallery and preview
- User and permission management
- Real-time logs and notifications

## 🚀 Quick Start

### Prerequisites
- Docker 20.10.0+
- Docker Compose 2.0.0+
- 4GB RAM (minimum)
- 10GB free disk space

### 1. Clone and Setup
```bash
# Clone the repository
git clone https://github.com/wronai/mediacamel.git
cd mediacamel

# Copy and configure environment variables
cp .env.example .env
# Edit .env file if needed

# Make setup script executable
chmod +x setup.sh
```

### 2. Start the System
```bash
# Build and start all services
./setup.sh
```

### 3. Access the Services
- **🌐 Web Dashboard:** http://localhost:8085
- **📁 WebDAV Server:** http://localhost:8081
- **🖥️ Filestash Client:** http://localhost:8082
- **🔧 API Documentation:** http://localhost:8084/api-docs

### 4. WebDAV Credentials
```
URL: http://localhost:8081
Username: webdav
Password: medavault123
```

### 5. Test the Connection
```bash
# Run the test script
./scripts/test-webdav.sh
```

## 📤 File Upload Methods

### 1. **Using Filestash (Easiest)**
1. Open http://localhost:8082
2. Select "WebDAV" as storage type
3. Enter WebDAV credentials:
   - URL: `http://webdav-server`
   - Username: `webdav`
   - Password: `medavault123`
4. Drag and drop files to upload

### 2. **Direct WebDAV Access**
#### Using curl:
```bash
curl -u webdav:medavault123 \
     -T your-file.jpg \
     "http://localhost:8081/your-file.jpg"
```

#### Using rclone:
1. Configure rclone:
   ```bash
   rclone config create webdav webdav \
     url=http://localhost:8081 \
     vendor=other \
     user=webdav \
     pass=medavault123
   ```
2. Copy files:
   ```bash
   rclone copy local-folder/ webdav:
   ```

### 3. **Mount as Network Drive**
#### Linux (davfs2):
```bash
# Install davfs2
sudo apt install davfs2

# Add user to davfs2 group
sudo usermod -aG davfs2 $(whoami)

# Mount WebDAV
sudo mount -t davfs http://localhost:8081 /mnt/webdav
```

#### Windows:
1. Open File Explorer
2. Right-click "This PC" and select "Map network drive"
3. Enter: `\\localhost@8081\`
4. Enter credentials when prompted

#### macOS:
1. In Finder, press Cmd+K
2. Enter: `http://localhost:8081`
3. Use "Connect As" with username/password

## 🔄 Processing Pipeline

1. **Upload**: User uploads file via WebDAV
2. **Detection**: Camel integration detects new file
3. **Download**: File is downloaded for processing
4. **Processing**:
   - Images: Generate thumbnails, extract metadata
   - Videos: Extract metadata, generate previews
   - Documents: Index content, extract text
5. **Storage**: File is stored in MedaVault
6. **Cleanup**: Optional removal from WebDAV after processing

## 📁 Project Structure

```
mediacamel/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env                       # Environment variables
├── config/                    # Configuration files
│   ├── nginx/                # Nginx configurations
│   ├── filestash/            # Filestash configuration
│   └── medavault/            # MedaVault application configs
├── camel-integration/         # Apache Camel integration
│   ├── Dockerfile
│   ├── CamelWebDAVProcessor.groovy
│   └── lib/                   # Custom Java/Groovy libraries
├── medavault-backend/         # Node.js API
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── web-dashboard/             # React/Vue dashboard
│   ├── public/
│   ├── src/
│   └── package.json
├── storage/                   # Persistent storage
│   ├── incoming/             # New uploads
│   ├── processed/            # Successfully processed files
│   └── failed/               # Failed processing attempts
├── scripts/                   # Utility scripts
│   ├── setup.sh              # Initial setup
│   ├── test-webdav.sh        # WebDAV connection test
│   └── backup.sh             # Backup utilities
└── logs/                     # Application logs
```

## 🔄 Storage Configuration

### S3 Storage
MedaVault uses MinIO as an S3-compatible object storage backend. Files can be accessed using any S3-compatible client.

**Configuration Options**:
- `S3_ENDPOINT`: MinIO server URL (default: http://minio:9000)
- `S3_BUCKET`: Default bucket name (default: medavault)
- `S3_ACCESS_KEY_ID`: Access key for S3 API
- `S3_SECRET_ACCESS_KEY`: Secret key for S3 API
- `S3_REGION`: AWS region (default: us-east-1)

**Example using AWS CLI**:
```bash
aws --endpoint-url http://localhost:9000 s3 ls s3://medavault
```

### WebDAV Integration
WebDAV is fully supported for both client access and as a storage backend.

**Configuration Options**:
- `WEBDAV_ENABLED`: Enable/disable WebDAV (default: true)
- `WEBDAV_URL`: Base URL for WebDAV server
- `WEBDAV_USERNAME`: Authentication username
- `WEBDAV_PASSWORD`: Authentication password

**Mounting WebDAV on Linux**:
```bash
sudo apt install davfs2
sudo mkdir /mnt/medavault
sudo mount -t davfs http://localhost:9081/webdav /mnt/medavault
```

## 🚀 Apache Camel Integration

MedaVault includes Apache Camel routes for advanced file processing and integration:

### Key Features
- **File Routing**: Automatically route files between different storage backends
- **Media Processing**: Generate thumbnails, extract metadata, transcode videos
- **Event-Driven**: React to file changes in real-time
- **Extensible**: Add custom processors and routes

### Example Route: WebDAV to S3 Sync
```java
from("webdav://{{webdav.host}}:{{webdav.port}}{{webdav.path}}?username={{webdav.username}}&password={{webdav.password}}&recursive=true")
    .routeId("webdav-to-s3")
    .log("Processing file: ${header.CamelFileName}")
    .process(exchange -> {
        // Add custom processing logic here
        String fileName = exchange.getIn().getHeader("CamelFileName", String.class);
        exchange.getIn().setHeader("CamelAwsS3Key", "processed/" + fileName);
    })
    .to("aws2-s3://{{s3.bucket}}?accessKey={{s3.accessKey}}&secretKey={{s3.secretKey}}®ion={{s3.region}}")
    .log("Successfully uploaded ${header.CamelFileName} to S3");
```

### Running Camel Routes
1. Place your Camel route files in the `camel-routes` directory
2. Configure the routes in `application.yml`
3. Restart the backend service:
   ```bash
   make restart backend
   ```

## 🛠️ System Management

### Monitoring Services
```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f service_name

# Check service status
docker-compose ps
```

### Common Tasks
```bash
# Restart a specific service
docker-compose restart service_name

# Rebuild and restart a service
docker-compose up -d --build service_name

# Access container shell
docker-compose exec service_name sh
```

### Maintenance
```bash
# Backup database
docker-compose exec medavault-db pg_dump -U postgres medavault > backup.sql

# Clean up old files
# Clean processed files older than 7 days
find storage/processed -type f -mtime +7 -delete

# Stop all services
docker-compose down
```

## ⚙️ Configuration

### Environment Variables
Edit the `.env` file to configure:
- Database credentials
- WebDAV authentication
- Storage paths
- Logging levels
- Service ports

### WebDAV Authentication
To change WebDAV credentials:
1. Edit the `.env` file:
   ```
   WEBDAV_USER=newuser
   WEBDAV_PASSWORD=newpassword
   ```
2. Rebuild the WebDAV server:
   ```bash
   docker-compose up -d --build webdav-server
   ```

### Storage Configuration
By default, files are stored in the `storage` directory. To change this:
1. Update `.env`:
   ```
   STORAGE_PATH=/path/to/your/storage
   ```
2. Ensure the directory exists and has proper permissions
3. Restart the services

### Logging
Logs are stored in the `logs` directory by default. You can configure log rotation and levels in the respective service configurations.

### Camel Processing Rules
Edit `config/application.properties` to configure processing rules:
```properties
# WebDAV connection
webdav.url=http://webdav-server
webdav.username=${WEBDAV_USER}
webdav.password=${WEBDAV_PASSWORD}

# Processing rules
camel.poll.delay=5000
camel.cleanup.processed=true

# MedaVault API
medavault.api.url=http://medavault-backend:8084/api
```

## 🛡️ Security

### 1. **Default Credentials**
Change default credentials in the `.env` file before deploying to production.

### 2. HTTPS in Production
Always use HTTPS with a valid SSL certificate in production environments.

### 3. Firewall Rules
Restrict access to ports:
- 8085 (Dashboard) - Admin access only
- 8081, 8082 (WebDAV/Filestash) - Trusted networks only
- 8084 (API) - Internal access recommended

### 4. Regular Updates
Keep all components updated:
```bash
docker-compose pull
docker-compose up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

1. Install development dependencies:
   ```bash
   # Install Node.js dependencies
   cd medavault-backend
   npm install
   
   # Install frontend dependencies
   cd ../web-dashboard
   npm install
   ```

2. Start development servers:
   ```bash
   # Backend with hot-reload
   cd medavault-backend
   npm run dev
   
   # Frontend with hot-reload
   cd ../web-dashboard
   npm run serve
   ```

## 🐛 Troubleshooting

### Common Issues

#### WebDAV Connection Issues
- Verify the WebDAV server is running: `docker-compose ps | grep webdav`
- Check logs: `docker-compose logs webdav-server`
- Test connection: `./scripts/test-webdav.sh`

#### Database Connection Issues
- Check if PostgreSQL is running: `docker-compose ps | grep db`
- View database logs: `docker-compose logs medavault-db`
- Test database connection:
  ```bash
  docker-compose exec medavault-db psql -U postgres -c "\l"
  ```

#### File Permission Issues
If you encounter permission errors:
```bash
# Set correct permissions on storage directories
sudo chown -R 1000:1000 storage/
sudo chmod -R 775 storage/
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For issues and feature requests, please open an issue in the repository.

---

<div align="center">
  Made with ❤️ by the MedaVault Team
</div>

## 🔧 API Endpoints

### Authentication

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "yourpassword"
}
```

#### Refresh Token
```http
POST /api/auth/refresh-token
Authorization: Bearer <refresh_token>
```

### Media Management

#### List Media
```http
GET /api/media
Authorization: Bearer <token>
```

#### Upload File
```http
POST /api/media/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

# Form Data:
# file: <file>
# metadata: {"title":"My File","description":"Description"}
```

#### Get Media
```http
GET /api/media/{id}
Authorization: Bearer <token>
```

### User Management

#### List Users
```http
GET /api/users
Authorization: Bearer <token>
```

#### Create User
```http
POST /api/users
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "newuser",
  "password": "securepassword",
  "email": "user@example.com",
  "role": "user"
}
```

### System Status

#### Health Check
```http
GET /api/health
```

#### System Info
```http
GET /api/system/info
Authorization: Bearer <token>
```

## 📚 Additional Resources

### WebDAV Clients

#### Linux
- **Nautilus**: Built-in support (Files > Connect to Server)
- **Dolphin**: Built-in WebDAV support
- **rclone**: Command-line tool

#### Windows
- **File Explorer**: Built-in WebDAV support
- **WinSCP**: Free SFTP, FTP, WebDAV client
- **Cyberduck**: Open source client

#### macOS
- **Finder**: Built-in WebDAV support
- **Transmit**: Feature-rich FTP/WebDAV client
- **ForkLift**: Dual-pane file manager

### Monitoring

#### Prometheus Metrics
```
GET /metrics
```

#### Log Files
- Application logs: `logs/app.log`
- Access logs: `logs/access.log`
- Error logs: `logs/error.log`

### Backup and Restore

#### Database Backup
```bash
# Create backup
docker-compose exec medavault-db pg_dump -U postgres medavault > backup_$(date +%Y%m%d).sql

# Restore from backup
cat backup_file.sql | docker-compose exec -T medavault-db psql -U postgres medavault
```

#### File Storage Backup
```bash
# Backup storage directory
tar -czvf medavault_storage_backup_$(date +%Y%m%d).tar.gz storage/

# Restore
mkdir -p storage
tar -xzvf medavault_storage_backup.tar.gz
```

## 🚀 Deployment

### Production Deployment

1. **Environment Setup**
   ```bash
   # Set production environment
   echo "NODE_ENV=production" >> .env
   
   # Update API URL
   echo "API_URL=https://yourdomain.com/api" >> .env
   
   # Set secure secrets
   openssl rand -base64 32 | sed 's/[^a-zA-Z0-9]//g' | head -c 32
   echo "JWT_SECRET=generated_secret_here" >> .env
   ```

2. **Start in Production Mode**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Set Up Reverse Proxy (Nginx Example)**
   ```nginx
   server {
       listen 80;
       server_name yourdomain.com;
       return 301 https://$host$request_uri;
   }

   server {
       listen 443 ssl http2;
       server_name yourdomain.com;

       ssl_certificate /path/to/cert.pem;
       ssl_certificate_key /path/to/key.pem;

       location / {
           proxy_pass http://localhost:8085;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }


       location /api {
           proxy_pass http://localhost:8084;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

## 🧪 Testing

### Run Tests
```bash
# Backend tests
cd medavault-backend
npm test

# Frontend tests
cd ../web-dashboard
npm test
```

### Test Coverage
```bash
# Backend coverage
cd medavault-backend
npm run test:coverage

# Frontend coverage
cd ../web-dashboard
npm run test:coverage
```

## 🌟 Features

### Core Features
- **Secure File Storage**: Encrypted storage with access control
- **Media Processing**: Automatic thumbnails and metadata extraction
- **User Management**: Role-based access control
- **API-First Design**: RESTful API for all operations
- **Web Interface**: Modern dashboard for easy management

### Advanced Features
- **WebDAV Support**: Standard protocol integration
- **File Versioning**: Keep track of file changes
- **Search**: Full-text search across all content
- **Tags & Collections**: Organize your media
- **Sharing**: Share files with external users

## 📈 Monitoring & Analytics

### Built-in Metrics
- File uploads/downloads
- Storage usage
- User activity
- System performance

### Integration
- **Prometheus** for metrics collection
- **Grafana** for visualization
- **ELK Stack** for log analysis

## 🔄 Upgrade Guide

### Version 1.0.0 to 2.0.0
1. Backup your data
2. Update the repository
3. Run database migrations
4. Update environment variables
5. Restart services

## 🤝 Community & Support

### Getting Help
- [GitHub Issues](https://github.com/wronai/mediacamel/issues) - Report bugs and request features
- [Discord](https://discord.gg/your-invite) - Join our community
- [Documentation](https://docs.medavault.example.com) - Full documentation

### Contributing
We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📜 Changelog

### [2.0.0] - 2025-06-13
#### Added
- WebDAV server integration
- File processing pipeline
- User authentication
- API documentation

### [1.0.0] - 2025-01-01
#### Added
- Initial release
- Basic file upload/download
- User management
- Web interface

## 📄 License

This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For issues and feature requests, please open an issue in the repository.

---

<div align="center">
  Made with ❤️ by the MedaVault Team
</div>

### MedaVault API (Port 8084)
```bash
# Get all media
GET /api/media

# Get media by type
GET /api/media?type=image&limit=10

# Get specific media
GET /api/media/{id}

# Download media
GET /api/media/{id}/download

# Get thumbnail
GET /api/media/{id}/thumbnail

# System statistics
GET /api/stats

# Health check
GET /health
```

### WebDAV API (Port 8081)
```bash
# List files
PROPFIND /webdav/

# Upload file
PUT /webdav/filename.jpg

# Download file
GET /webdav/filename.jpg

# Delete file
DELETE /webdav/filename.jpg

# Create directory
MKCOL /webdav/newfolder/
```

## 🚨 Troubleshooting

### Camel nie wykrywa plików
```bash
# Sprawdź logi Camel
docker-compose logs camel-integration

# Zweryfikuj połączenie z WebDAV
curl -u webdav:medavault123 \
     -X PROPFIND \
     "http://localhost:8081/webdav/"
```

### Filestash nie łączy się z WebDAV
1. Sprawdź czy WebDAV server działa: http://localhost:8081/status
2. Zweryfikuj dane logowania
3. Sprawdź CORS headers w nginx config

### Upload fails
```bash
# Check WebDAV permissions
docker-compose exec webdav-server ls -la /var/www/webdav

# Check storage space
df -h storage/
```

### Database connection issues
```bash
# Restart database
docker-compose restart medavault-db

# Check database logs
docker-compose logs medavault-db
```

## 📊 Performance & Scaling

### File Processing Performance
- **Images:** ~100ms per thumbnail
- **Videos:** ~2-5s per file (metadata extraction)
- **Documents:** ~50ms per file
- **Concurrent Processing:** 5 files simultaneously

### Storage Recommendations
- **Development:** 10GB+ free space
- **Production:** 100GB+ with backup
- **Database:** SSD recommended for metadata

### Scaling Options
1. **Horizontal:** Multiple Camel instances
2. **Storage:** External S3/MinIO backend
3. **Database:** PostgreSQL cluster
4. **Load Balancing:** nginx upstream

## 🔒 Security

### Production Deployment
1. **HTTPS:** Enable SSL certificates
2. **Authentication:** Replace basic auth with OAuth/LDAP
3. **Network:** Firewall rules, VPN access
4. **Backup:** Regular database and storage backups

### Security Headers
```nginx
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
```

## 📈 Monitoring & Alerting

### Metrics to Monitor
- WebDAV upload success rate
- Camel processing latency
- Database connection health
- Storage space utilization
- Failed processing count

### Log Aggregation
```bash
# Centralized logging with ELK stack
docker-compose logs | logstash -f logstash.conf
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📝 WebDAV Connection Instructions and Usage Guide

### Connecting to WebDAV

To connect to the WebDAV server, use the following URL: `http://localhost:8081/webdav/`

### Uploading Files

To upload a file, use the `PUT` method with the file path as the request body. For example:
```bash
curl -u webdav:medavault123 \
     -T test.txt \
     "http://localhost:8081/webdav/test.txt"
```

### Downloading Files

To download a file, use the `GET` method with the file path as the request URL. For example:
```bash
curl -u webdav:medavault123 \
     "http://localhost:8081/webdav/test.txt"
```

### Deleting Files

To delete a file, use the `DELETE` method with the file path as the request URL. For example:
```bash
curl -u webdav:medavault123 \
     -X DELETE \
     "http://localhost:8081/webdav/test.txt"
```

## 📄 License

This project is licensed under the Apache 2.0 License.

## 🆘 Support

- **Issues:** GitHub Issues
- **Documentation:** This README
- **Community:** Discord/Slack channel

---

**🎉 Enjoy your WebDAV + Camel + MedaVault system!**

Built with ❤️ using:
- Filestash for WebDAV web client
- Apache Camel for integration
- Sardine for WebDAV connectivity
- PostgreSQL for metadata storage
- Bootstrap for responsive UI
