// Configuration for the dashboard loaded from environment variables
const config = {
    // WebDAV configuration
    webdav: {
        httpPort: process.env.WEBDAV_PORT_HTTP || '9081',
        httpsPort: process.env.WEBDAV_PORT_HTTPS || '9443',
        statusPort: process.env.WEBDAV_STATUS_PORT || '9082',
        username: process.env.WEBDAV_USER || 'webdav',
        password: process.env.WEBDAV_PASSWORD || 'medavault123',
        host: process.env.WEBDAV_HOST || 'localhost'
    },
    
    // Filestash configuration
    filestash: {
        port: process.env.FILESTASH_PORT || '9083',
        host: process.env.FILESTASH_HOST || 'localhost'
    },
    
    // MedaVault Backend configuration
    medavault: {
        port: process.env.BACKEND_PORT || '9084',
        host: process.env.BACKEND_HOST || 'localhost',
        apiPath: process.env.API_BASE_PATH || '/api'
    },
    
    // Dashboard configuration
    dashboard: {
        port: process.env.DASHBOARD_PORT || '9085',
        host: process.env.DASHBOARD_HOST || 'localhost'
    }
};

// Export the configuration
export { config };

// Make it globally available for non-module scripts
window.appConfig = config;
