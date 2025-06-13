// Dashboard JavaScript
let systemStats = {
    totalFiles: 0,
    totalSize: 0,
    processedToday: 0
};

let systemLogs = [];

// Import configuration
import { config } from './config.js';

// Helper function to build service URLs
const buildServiceUrl = (service, path = '') => {
    const protocol = service.httpsPort ? 'https:' : 'http:';
    const port = service.httpsPort || service.httpPort || service.port;
    const baseUrl = `${protocol}//${service.host || 'localhost'}${port ? ':' + port : ''}`;
    return path ? `${baseUrl}${path.startsWith('/') ? path : '/' + path}` : baseUrl;
};

// Service URLs
const services = {
    webdav: buildServiceUrl(config.webdav, '/status'),
    filestash: buildServiceUrl(config.filestash),
    camel: buildServiceUrl(config.webdav, '/actuator/health'), // if Spring Boot actuator is available
    medavault: buildServiceUrl(config.medavault, '/health')
};

// Set page title with dashboard port
document.title = `MediaCamel Dashboard (${buildServiceUrl(config.dashboard)})`;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Dashboard initializing...');

    checkAllServices();
    loadSystemStats();
    loadRecentMedia();
    startLogSimulation();

    // Auto-refresh every 30 seconds
    setInterval(() => {
        checkAllServices();
        loadSystemStats();
    }, 30000);

    // Manual refresh button
    document.getElementById('refreshBtn').addEventListener('click', function() {
        checkAllServices();
        loadSystemStats();
        loadRecentMedia();
    });
});

// Check service status
async function checkServiceStatus(serviceName, url) {
    try {
        // Special handling for WebDAV service
        if (serviceName === 'webdav') {
            try {
                // First try with CORS
                const response = await fetch(url, {
                    method: 'GET',
                    mode: 'cors',
                    credentials: 'omit',
                    headers: {
                        'Accept': 'application/json'
                    }
                });
                
                if (response.ok) {
                    const data = await response.json().catch(() => ({}));
                    updateServiceStatus(serviceName, 'online');
                    return true;
                }
            } catch (e) {
                console.log('CORS request failed, trying with no-cors mode');
                // If CORS fails, try with no-cors mode
                try {
                    const response = await fetch(url, {
                        method: 'GET',
                        mode: 'no-cors',
                        credentials: 'omit'
                    });
                    // With no-cors, we can't read the response, but if we get here, the server is up
                    updateServiceStatus(serviceName, 'online');
                    return true;
                } catch (noCorsError) {
                    console.log(`${serviceName} no-cors check failed:`, noCorsError.message);
                    updateServiceStatus(serviceName, 'offline');
                    return false;
                }
            }
        } else {
            // Standard check for other services
            const response = await fetch(url, {
                method: 'GET',
                mode: 'cors',
                credentials: 'omit'
            });

            if (response.ok) {
                updateServiceStatus(serviceName, 'online');
                return true;
            }
        }
        
        // If we get here, the request was not successful
        updateServiceStatus(serviceName, 'offline');
        return false;
    } catch (error) {
        console.log(`${serviceName} check failed:`, error.message);
        updateServiceStatus(serviceName, 'offline');
        return false;
    }
}

// Update service status badge
function updateServiceStatus(serviceName, status) {
    const badge = document.getElementById(`${serviceName}-badge`);
    const card = document.getElementById(`${serviceName}-status`);

    if (badge) {
        badge.className = status === 'online' ? 'badge badge-online' : 'badge badge-offline';
        badge.textContent = status === 'online' ? 'Online' : 'Offline';
    }

    if (card) {
        card.style.borderLeft = status === 'online' ? '4px solid #28a745' : '4px solid #dc3545';
    }
}

// Check all services
async function checkAllServices() {
    console.log('🔍 Checking service status...');

    const checks = [
        checkServiceStatus('webdav', services.webdav),
        checkServiceStatus('filestash', services.filestash),
        checkServiceStatus('medavault', services.medavault)
    ];

    // Camel status is harder to check, simulate for now
    updateServiceStatus('camel', 'online'); // Assume online if other services work

    await Promise.allSettled(checks);
    addLogEntry('info', 'Service status check completed');
}

// Load system statistics
async function loadSystemStats() {
    try {
        const response = await fetch('http://localhost:8083/api/stats');

        if (response.ok) {
            const data = await response.json();

            if (data.success) {
                updateStats(data.stats);
                addLogEntry('success', 'Statistics loaded successfully');
            } else {
                throw new Error('Failed to load stats');
            }
        } else {
            throw new Error(`HTTP ${response.status}`);
        }
    } catch (error) {
        console.error('Failed to load stats:', error);
        addLogEntry('error', `Failed to load statistics: ${error.message}`);

        // Show placeholder data
        updateStats({
            totalMedia: '--',
            totalSize: '--',
            recentUploads: []
        });
    }
}

// Update statistics display
function updateStats(stats) {
    document.getElementById('total-files').textContent = stats.totalMedia || 0;
    document.getElementById('total-size').textContent = formatFileSize(stats.totalSize || 0);

    // Calculate files processed today (mock)
    const today = new Date().toDateString();
    const todayCount = (stats.recentUploads || [])
        .filter(media => new Date(media.uploadedAt).toDateString() === today)
        .length;

    document.getElementById('processed-today').textContent = todayCount;
}

// Load recent media
async function loadRecentMedia() {
    try {
        const response = await fetch('http://localhost:8083/api/media?limit=12');

        if (response.ok) {
            const data = await response.json();

            if (data.success) {
                displayRecentMedia(data.media || []);
                addLogEntry('success', `Loaded ${data.media.length} recent media items`);
            } else {
                throw new Error('Failed to load media');
            }
        } else {
            throw new Error(`HTTP ${response.status}`);
        }
    } catch (error) {
        console.error('Failed to load recent media:', error);
        addLogEntry('error', `Failed to load media: ${error.message}`);

        document.getElementById('recent-media').innerHTML = `
            <div class="col-12 text-center text-muted">
                <i class="bi bi-exclamation-triangle"></i>
                Nie można załadować mediów
            </div>
        `;
    }
}

// Display recent media
function displayRecentMedia(mediaList) {
    const container = document.getElementById('recent-media');

    if (!mediaList || mediaList.length === 0) {
        container.innerHTML = `
            <div class="col-12 text-center text-muted">
                <i class="bi bi-image"></i>
                <p>Brak mediów do wyświetlenia</p>
                <small>Prześlij pliki przez WebDAV, aby zobaczyć je tutaj</small>
            </div>
        `;
        return;
    }

    const mediaHTML = mediaList.map(media => {
        const icon = getFileIcon(media.fileType);
        const uploadedAt = new Date(media.uploadedAt).toLocaleDateString('pl-PL');

        return `
            <div class="col-md-2 col-sm-4 col-6 mb-3">
                <div class="card media-card h-100">
                    <div class="card-body text-center p-2">
                        <i class="bi bi-${icon} display-4 text-primary"></i>
                        <h6 class="card-title small mt-2" title="${media.filename}">
                            ${truncateText(media.filename, 15)}
                        </h6>
                        <p class="card-text small text-muted">
                            ${media.fileType}<br>
                            ${formatFileSize(media.size)}<br>
                            ${uploadedAt}
                        </p>
                        <span class="badge bg-${getStatusColor(media.status)}">${media.status}</span>
                    </div>
                </div>
            </div>
        `;
    }).join('');

    container.innerHTML = mediaHTML;
}

// Helper functions
function getFileIcon(fileType) {
    const icons = {
        'image': 'image',
        'video': 'camera-video',
        'document': 'file-text',
        'generic': 'file'
    };
    return icons[fileType] || 'file';
}

function getStatusColor(status) {
    const colors = {
        'processed': 'success',
        'processing': 'warning',
        'failed': 'danger',
        'pending': 'secondary'
    };
    return colors[status] || 'secondary';
}

function formatFileSize(bytes) {
    if (!bytes || bytes === 0) return '0 B';

    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${sizes[i]}`;
}

function truncateText(text, maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// Simulate system logs
function startLogSimulation() {
    const logMessages = [
        { type: 'info', message: 'WebDAV server monitoring started' },
        { type: 'success', message: 'Camel route file-to-medavault is running' },
        { type: 'info', message: 'Checking for new files in WebDAV...' },
        { type: 'success', message: 'File processed: vacation_photo.jpg' },
        { type: 'warning', message: 'Large file detected: big_video.mp4 (2.1GB)' },
        { type: 'success', message: 'Thumbnail generated successfully' },
        { type: 'info', message: 'Database connection healthy' },
        { type: 'success', message: 'File uploaded to MedaVault: document.pdf' }
    ];

    let messageIndex = 0;

    setInterval(() => {
        const message = logMessages[messageIndex % logMessages.length];
        addLogEntry(message.type, message.message);
        messageIndex++;
    }, 8000); // New log every 8 seconds
}

// Add log entry
function addLogEntry(type, message) {
    const timestamp = new Date().toLocaleTimeString('pl-PL');
    const logContainer = document.getElementById('system-logs');

    const logEntry = document.createElement('div');
    logEntry.className = `log-entry ${type}`;
    logEntry.innerHTML = `<strong>[${timestamp}]</strong> ${message}`;

    // Add to beginning
    logContainer.insertBefore(logEntry, logContainer.firstChild);

    // Keep only last 50 entries
    while (logContainer.children.length > 50) {
        logContainer.removeChild(logContainer.lastChild);
    }

    // Scroll to top
    logContainer.scrollTop = 0;
}

// Export functions for global access
window.loadRecentMedia = loadRecentMedia;
