-- MedaVault Database Schema
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    role VARCHAR(50) NOT NULL DEFAULT 'external_client',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT DEFAULT 0,
    processed_path TEXT,
    thumbnail_path TEXT,
    source VARCHAR(50) DEFAULT 'upload',
    status VARCHAR(50) DEFAULT 'pending',
    metadata JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    last_modified TIMESTAMP
);

CREATE TABLE IF NOT EXISTS processing_jobs (
    id SERIAL PRIMARY KEY,
    media_id UUID REFERENCES media(id),
    job_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    result_data JSONB DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS webdav_sync_log (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    webdav_url TEXT NOT NULL,
    action VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    error_message TEXT,
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default users
INSERT INTO users (username, email, role) VALUES
    ('admin', 'admin@medavault.local', 'administrator'),
    ('manager', 'manager@medavault.local', 'manager'),
    ('client', 'client@medavault.local', 'external_client')
ON CONFLICT (username) DO NOTHING;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_media_type ON media(file_type);
CREATE INDEX IF NOT EXISTS idx_media_uploaded_at ON media(uploaded_at);
CREATE INDEX IF NOT EXISTS idx_media_status ON media(status);
CREATE INDEX IF NOT EXISTS idx_processing_jobs_status ON processing_jobs(status);
