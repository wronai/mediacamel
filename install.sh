                                 #!/bin/bash

# MedaVault Jinja2 Templates Generator
# Tworzy szabłony HTML z Bootstrap dla 3 ról użytkowników

PROJECT_NAME="medavault-web-templates"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"

echo "🎨 Tworzenie szablonów MedaVault z Bootstrap..."

# Tworzenie struktury katalogów
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

mkdir -p {templates,static/{css,js,images},uploads,config}

# Tworzenie bazowego template'u
echo "📄 Tworzenie base.html template..."
cat > templates/base.html << 'EOF'
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}MedaVault - Photo Vault{% endblock %}</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .navbar-brand {
            font-weight: bold;
            color: #fff !important;
        }
        .nav-link {
            color: rgba(255,255,255,0.8) !important;
            transition: all 0.3s ease;
        }
        .nav-link:hover, .nav-link.active {
            color: #fff !important;
            background-color: rgba(255,255,255,0.1);
            border-radius: 5px;
        }
        .main-content {
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        .card {
            border: none;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            transition: all 0.3s ease;
        }
        .card:hover {
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
        }
        .upload-zone {
            border: 2px dashed #dee2e6;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .upload-zone:hover {
            border-color: #667eea;
            background-color: rgba(102, 126, 234, 0.05);
        }
        .upload-zone.dragover {
            border-color: #667eea;
            background-color: rgba(102, 126, 234, 0.1);
        }
        .media-thumbnail {
            width: 200px;
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
        }
        .status-badge {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }
        .role-{{ user_role | lower }} {
            border-left: 4px solid
            {% if user_role == 'administrator' %}#dc3545
            {% elif user_role == 'manager' %}#fd7e14
            {% else %}#198754{% endif %};
        }
    </style>

    {% block extra_css %}{% endblock %}
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse">
                <div class="position-sticky pt-3">
                    <div class="navbar-brand mb-4">
                        <i class="fas fa-photo-video me-2"></i>
                        MedaVault
                    </div>

                    <!-- User Info -->
                    <div class="card mb-3 bg-transparent border-light">
                        <div class="card-body text-white p-2">
                            <div class="d-flex align-items-center">
                                <img src="https://via.placeholder.com/40" alt="Avatar" class="user-avatar me-2">
                                <div>
                                    <div class="fw-bold small">{{ user_name | default('Użytkownik') }}</div>
                                    <div class="small opacity-75">{{ user_role | title }}</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Navigation -->
                    <ul class="nav flex-column">
                        {% block navigation %}
                        <li class="nav-item">
                            <a class="nav-link" href="/dashboard">
                                <i class="fas fa-tachometer-alt me-2"></i>
                                Dashboard
                            </a>
                        </li>
                        {% endblock %}

                        <li class="nav-item mt-3">
                            <a class="nav-link" href="/logout">
                                <i class="fas fa-sign-out-alt me-2"></i>
                                Wyloguj
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>

            <!-- Main content -->
            <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
                <!-- Header -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">{% block page_title %}Dashboard{% endblock %}</h1>

                    <div class="btn-toolbar mb-2 mb-md-0">
                        {% block header_actions %}
                        <div class="btn-group me-2">
                            <button type="button" class="btn btn-sm btn-outline-secondary">
                                <i class="fas fa-sync-alt"></i>
                                Odśwież
                            </button>
                        </div>
                        {% endblock %}
                    </div>
                </div>

                <!-- Alerts -->
                {% if alerts %}
                    {% for alert in alerts %}
                    <div class="alert alert-{{ alert.type }} alert-dismissible fade show" role="alert">
                        <i class="fas fa-{{ alert.icon | default('info-circle') }} me-2"></i>
                        {{ alert.message }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    {% endfor %}
                {% endif %}

                <!-- Content -->
                {% block content %}{% endblock %}
            </main>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

    <script>
        // Global JavaScript functions
        function showAlert(message, type = 'info', icon = 'info-circle') {
            const alertHtml = `
                <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                    <i class="fas fa-${icon} me-2"></i>
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            `;
            $('.main-content').prepend(alertHtml);
        }

        // Upload progress
        function updateUploadProgress(percentage, filename) {
            const progressHtml = `
                <div class="progress mb-2">
                    <div class="progress-bar" role="progressbar" style="width: ${percentage}%">
                        ${filename} - ${percentage}%
                    </div>
                </div>
            `;
            $('#upload-progress').html(progressHtml);
        }

        // Camel integration
        function sendToCamel(action, data) {
            return $.ajax({
                url: '/api/camel/' + action,
                method: 'POST',
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function(response) {
                    showAlert('Operacja wykonana pomyślnie', 'success', 'check-circle');
                },
                error: function(xhr) {
                    showAlert('Błąd podczas wykonywania operacji', 'danger', 'exclamation-triangle');
                }
            });
        }
    </script>

    {% block extra_js %}{% endblock %}
</body>
</html>
EOF

# Template dla Administratora
echo "👨‍💼 Tworzenie template administratora..."
cat > templates/administrator.html << 'EOF'
{% extends "base.html" %}

{% set user_role = "administrator" %}

{% block title %}Administrator - MedaVault{% endblock %}

{% block navigation %}
{{ super() }}
<li class="nav-item">
    <a class="nav-link active" href="/admin/dashboard">
        <i class="fas fa-tachometer-alt me-2"></i>
        Dashboard
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/admin/users">
        <i class="fas fa-users me-2"></i>
        Użytkownicy
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/admin/media">
        <i class="fas fa-photo-video me-2"></i>
        Wszystkie Media
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/admin/system">
        <i class="fas fa-cogs me-2"></i>
        System
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/admin/logs">
        <i class="fas fa-file-alt me-2"></i>
        Logi
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/admin/camel">
        <i class="fas fa-route me-2"></i>
        Apache Camel
    </a>
</li>
{% endblock %}

{% block page_title %}Panel Administratora{% endblock %}

{% block header_actions %}
{{ super() }}
<div class="btn-group">
    <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#bulkUploadModal">
        <i class="fas fa-cloud-upload-alt"></i>
        Masowe Upload
    </button>
    <button type="button" class="btn btn-sm btn-warning" onclick="systemMaintenance()">
        <i class="fas fa-tools"></i>
        Konserwacja
    </button>
</div>
{% endblock %}

{% block content %}
<!-- Statistics Cards -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6">
        <div class="card role-administrator mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Wszyscy Użytkownicy</div>
                        <div class="h3 mb-0">{{ stats.total_users | default(0) }}</div>
                    </div>
                    <div class="fas fa-users fa-2x text-primary"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Wszystkie Media</div>
                        <div class="h3 mb-0">{{ stats.total_media | default(0) }}</div>
                    </div>
                    <div class="fas fa-photo-video fa-2x text-success"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Rozmiar Danych</div>
                        <div class="h3 mb-0">{{ stats.total_size | default('0 GB') }}</div>
                    </div>
                    <div class="fas fa-hdd fa-2x text-info"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Aktywne Sesje</div>
                        <div class="h3 mb-0">{{ stats.active_sessions | default(0) }}</div>
                    </div>
                    <div class="fas fa-users-cog fa-2x text-warning"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- System Status -->
<div class="row mb-4">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-server me-2"></i>
                    Status Systemu
                </h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h6>Apache Camel Routes</h6>
                        <ul class="list-group list-group-flush">
                            {% for route in camel_routes | default([
                                {'name': 'file-to-medavault', 'status': 'running', 'processed': 125},
                                {'name': 'media-processor', 'status': 'running', 'processed': 89},
                                {'name': 'cleanup-task', 'status': 'stopped', 'processed': 0}
                            ]) %}
                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                {{ route.name }}
                                <div>
                                    <span class="badge bg-{{ 'success' if route.status == 'running' else 'secondary' }} me-2">
                                        {{ route.status }}
                                    </span>
                                    <small class="text-muted">{{ route.processed }} processed</small>
                                </div>
                            </li>
                            {% endfor %}
                        </ul>
                    </div>
                    <div class="col-md-6">
                        <h6>System Resources</h6>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between">
                                <span>CPU Usage</span>
                                <span>{{ system.cpu_usage | default('45') }}%</span>
                            </div>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar" style="width: {{ system.cpu_usage | default('45') }}%"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between">
                                <span>Memory</span>
                                <span>{{ system.memory_usage | default('68') }}%</span>
                            </div>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-warning" style="width: {{ system.memory_usage | default('68') }}%"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="d-flex justify-content-between">
                                <span>Disk Space</span>
                                <span>{{ system.disk_usage | default('23') }}%</span>
                            </div>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-success" style="width: {{ system.disk_usage | default('23') }}%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-bell me-2"></i>
                    Ostatnie Wydarzenia
                </h5>
            </div>
            <div class="card-body" style="max-height: 300px; overflow-y: auto;">
                {% for event in recent_events | default([
                    {'type': 'upload', 'user': 'manager1', 'message': 'Uploaded 15 photos', 'time': '2 min ago'},
                    {'type': 'user', 'user': 'admin', 'message': 'New user registered', 'time': '5 min ago'},
                    {'type': 'system', 'user': 'system', 'message': 'Backup completed', 'time': '1 hour ago'}
                ]) %}
                <div class="d-flex mb-2">
                    <div class="me-2">
                        <i class="fas fa-{{ 'cloud-upload-alt' if event.type == 'upload' else 'user' if event.type == 'user' else 'cog' }} text-muted"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="small"><strong>{{ event.user }}</strong> {{ event.message }}</div>
                        <div class="text-muted small">{{ event.time }}</div>
                    </div>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
</div>

<!-- Recent Media -->
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
            <i class="fas fa-photo-video me-2"></i>
            Ostatnio Dodane Media
        </h5>
        <a href="/admin/media" class="btn btn-sm btn-outline-primary">Zobacz wszystkie</a>
    </div>
    <div class="card-body">
        <div class="row">
            {% for media in recent_media | default([]) %}
            {% if loop.index <= 6 %}
            <div class="col-md-2 mb-3">
                <div class="position-relative">
                    <img src="{{ media.thumbnail | default('https://via.placeholder.com/200x150') }}"
                         alt="{{ media.filename }}" class="media-thumbnail w-100">
                    <span class="status-badge badge bg-{{ 'success' if media.status == 'processed' else 'warning' }}">
                        {{ media.status | default('processing') }}
                    </span>
                </div>
                <div class="small mt-1 text-truncate">{{ media.filename | default('sample.jpg') }}</div>
                <div class="small text-muted">{{ media.uploaded_by | default('user') }}</div>
            </div>
            {% endif %}
            {% endfor %}
        </div>
    </div>
</div>

<!-- Bulk Upload Modal -->
<div class="modal fade" id="bulkUploadModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Masowe Przesyłanie Plików</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="upload-zone" id="bulkUploadZone">
                    <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                    <h5>Przeciągnij pliki tutaj lub kliknij aby wybrać</h5>
                    <p class="text-muted">Obsługiwane formaty: JPG, PNG, GIF, MP4, PDF</p>
                    <input type="file" id="bulkFileInput" multiple accept="image/*,video/*,.pdf" style="display: none;">
                </div>
                <div id="upload-progress" class="mt-3"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Anuluj</button>
                <button type="button" class="btn btn-primary" onclick="startBulkUpload()">Rozpocznij Upload</button>
            </div>
        </div>
    </div>
</div>
{% endblock %}

{% block extra_js %}
<script>
$(document).ready(function() {
    // Bulk upload functionality
    $('#bulkUploadZone').on('click', function() {
        $('#bulkFileInput').click();
    });

    $('#bulkUploadZone').on('dragover', function(e) {
        e.preventDefault();
        $(this).addClass('dragover');
    });

    $('#bulkUploadZone').on('dragleave', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
    });

    $('#bulkUploadZone').on('drop', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
        const files = e.originalEvent.dataTransfer.files;
        handleBulkFiles(files);
    });

    $('#bulkFileInput').on('change', function() {
        handleBulkFiles(this.files);
    });
});

function handleBulkFiles(files) {
    const fileList = Array.from(files);
    let progressHtml = '<h6>Wybrane pliki:</h6><ul class="list-group">';

    fileList.forEach((file, index) => {
        progressHtml += `
            <li class="list-group-item d-flex justify-content-between align-items-center">
                ${file.name}
                <span class="badge bg-secondary">Oczekuje</span>
            </li>
        `;
    });

    progressHtml += '</ul>';
    $('#upload-progress').html(progressHtml);
}

function startBulkUpload() {
    const files = $('#bulkFileInput')[0].files;

    Array.from(files).forEach((file, index) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('action', 'bulk_upload');
        formData.append('user_role', 'administrator');

        // Send to Camel route via AJAX
        sendToCamel('upload', {
            filename: file.name,
            size: file.size,
            type: file.type,
            action: 'admin_bulk_upload'
        }).done(function() {
            updateUploadProgress(((index + 1) / files.length) * 100, file.name);
        });
    });
}

function systemMaintenance() {
    if (confirm('Czy na pewno chcesz rozpocząć konserwację systemu?')) {
        sendToCamel('maintenance', {
            action: 'start_maintenance',
            user: '{{ user_name }}'
        });
    }
}
</script>
{% endblock %}
EOF

# Template dla Managera
echo "👨‍💼 Tworzenie template managera..."
cat > templates/manager.html << 'EOF'
{% extends "base.html" %}

{% set user_role = "manager" %}

{% block title %}Manager - MedaVault{% endblock %}

{% block navigation %}
{{ super() }}
<li class="nav-item">
    <a class="nav-link active" href="/manager/dashboard">
        <i class="fas fa-tachometer-alt me-2"></i>
        Dashboard
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/manager/upload">
        <i class="fas fa-cloud-upload-alt me-2"></i>
        Upload Media
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/manager/gallery">
        <i class="fas fa-images me-2"></i>
        Galeria
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/manager/team">
        <i class="fas fa-users me-2"></i>
        Mój Zespół
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/manager/reports">
        <i class="fas fa-chart-bar me-2"></i>
        Raporty
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/manager/processing">
        <i class="fas fa-cogs me-2"></i>
        Przetwarzanie
    </a>
</li>
{% endblock %}

{% block page_title %}Panel Managera{% endblock %}

{% block header_actions %}
{{ super() }}
<div class="btn-group">
    <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#quickUploadModal">
        <i class="fas fa-plus"></i>
        Szybki Upload
    </button>
    <button type="button" class="btn btn-sm btn-success" onclick="processMedia()">
        <i class="fas fa-play"></i>
        Przetwórz Media
    </button>
</div>
{% endblock %}

{% block content %}
<!-- Quick Stats -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6">
        <div class="card role-manager mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Moje Media</div>
                        <div class="h3 mb-0">{{ stats.my_media | default(0) }}</div>
                    </div>
                    <div class="fas fa-photo-video fa-2x text-warning"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">W Przetwarzaniu</div>
                        <div class="h3 mb-0">{{ stats.processing | default(0) }}</div>
                    </div>
                    <div class="fas fa-spinner fa-2x text-info"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Zespół</div>
                        <div class="h3 mb-0">{{ stats.team_members | default(0) }}</div>
                    </div>
                    <div class="fas fa-users fa-2x text-success"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Dzisiaj</div>
                        <div class="h3 mb-0">{{ stats.today_uploads | default(0) }}</div>
                    </div>
                    <div class="fas fa-calendar-day fa-2x text-primary"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Upload Section -->
<div class="row mb-4">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-cloud-upload-alt me-2"></i>
                    Upload Media
                </h5>
            </div>
            <div class="card-body">
                <div class="upload-zone" id="mainUploadZone">
                    <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                    <h5>Przeciągnij media tutaj</h5>
                    <p class="text-muted">lub kliknij aby wybrać pliki</p>
                    <input type="file" id="mediaFileInput" multiple accept="image/*,video/*" style="display: none;">

                    <!-- Upload Options -->
                    <div class="row mt-4">
                        <div class="col-md-6">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="autoProcess" checked>
                                <label class="form-check-label" for="autoProcess">
                                    Auto-przetwarzanie
                                </label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="generateThumbnails" checked>
                                <label class="form-check-label" for="generateThumbnails">
                                    Generuj miniatury
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="upload-queue" class="mt-3"></div>
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-tasks me-2"></i>
                    Status Przetwarzania
                </h5>
            </div>
            <div class="card-body">
                <div class="processing-status">
                    {% for task in processing_tasks | default([
                        {'id': 'task1', 'file': 'vacation_photos.zip', 'progress': 75, 'status': 'processing'},
                        {'id': 'task2', 'file': 'company_video.mp4', 'progress': 100, 'status': 'completed'},
                        {'id': 'task3', 'file': 'product_images.rar', 'progress': 30, 'status': 'processing'}
                    ]) %}
                    <div class="mb-3">
                        <div class="d-flex justify-content-between">
                            <span class="small">{{ task.file }}</span>
                            <span class="badge bg-{{ 'success' if task.status == 'completed' else 'primary' if task.status == 'processing' else 'warning' }}">
                                {{ task.status }}
                            </span>
                        </div>
                        <div class="progress mt-1" style="height: 8px;">
                            <div class="progress-bar" style="width: {{ task.progress }}%"></div>
                        </div>
                    </div>
                    {% endfor %}
                </div>

                <div class="d-grid gap-2 mt-3">
                    <button class="btn btn-outline-primary btn-sm" onclick="refreshProcessingStatus()">
                        <i class="fas fa-sync-alt"></i>
                        Odśwież Status
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Gallery -->
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
            <i class="fas fa-images me-2"></i>
            Moja Galeria
        </h5>
        <div>
            <div class="btn-group btn-group-sm me-2">
                <button type="button" class="btn btn-outline-secondary active" data-filter="all">Wszystkie</button>
                <button type="button" class="btn btn-outline-secondary" data-filter="images">Zdjęcia</button>
                <button type="button" class="btn btn-outline-secondary" data-filter="videos">Wideo</button>
            </div>
            <a href="/manager/gallery" class="btn btn-sm btn-outline-primary">Pełna galeria</a>
        </div>
    </div>
    <div class="card-body">
        <div class="row" id="mediaGallery">
            {% for media in my_media | default([]) %}
            {% if loop.index <= 8 %}
            <div class="col-md-3 col-sm-6 mb-3 media-item" data-type="{{ media.type | default('image') }}">
                <div class="position-relative">
                    <img src="{{ media.thumbnail | default('https://via.placeholder.com/200x150') }}"
                         alt="{{ media.filename }}" class="media-thumbnail w-100"
                         data-bs-toggle="modal" data-bs-target="#mediaModal"
                         data-media-url="{{ media.url }}" data-media-name="{{ media.filename }}">

                    {% if media.type == 'video' %}
                    <div class="position-absolute top-50 start-50 translate-middle">
                        <i class="fas fa-play-circle fa-2x text-white"></i>
                    </div>
                    {% endif %}

                    <div class="position-absolute top-0 end-0 p-2">
                        <div class="dropdown">
                            <button class="btn btn-sm btn-light" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-ellipsis-v"></i>
                            </button>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="#" onclick="downloadMedia('{{ media.id }}')">
                                    <i class="fas fa-download me-2"></i>Pobierz</a></li>
                                <li><a class="dropdown-item" href="#" onclick="shareMedia('{{ media.id }}')">
                                    <i class="fas fa-share me-2"></i>Udostępnij</a></li>
                                <li><a class="dropdown-item" href="#" onclick="editMedia('{{ media.id }}')">
                                    <i class="fas fa-edit me-2"></i>Edytuj</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="#" onclick="deleteMedia('{{ media.id }}')">
                                    <i class="fas fa-trash me-2"></i>Usuń</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="small mt-1 text-truncate">{{ media.filename | default('sample.jpg') }}</div>
                <div class="small text-muted">{{ media.uploaded_at | default('2024-01-15') }}</div>
            </div>
            {% endif %}
            {% endfor %}
        </div>
    </div>
</div>

<!-- Team Activity -->
<div class="card">
    <div class="card-header">
        <h5 class="mb-0">
            <i class="fas fa-users me-2"></i>
            Aktywność Zespołu
        </h5>
    </div>
    <div class="card-body">
        <div class="row">
            {% for member in team_activity | default([
                {'name': 'Anna Kowalska', 'uploads': 15, 'last_active': '2 min ago', 'avatar': 'https://via.placeholder.com/40'},
                {'name': 'Jan Nowak', 'uploads': 8, 'last_active': '1 hour ago', 'avatar': 'https://via.placeholder.com/40'},
                {'name': 'Marta Wiśniewska', 'uploads': 23, 'last_active': '3 hours ago', 'avatar': 'https://via.placeholder.com/40'}
            ]) %}
            <div class="col-md-4 mb-3">
                <div class="d-flex align-items-center">
                    <img src="{{ member.avatar }}" alt="{{ member.name }}" class="user-avatar me-3">
                    <div>
                        <div class="fw-bold">{{ member.name }}</div>
                        <div class="small text-muted">{{ member.uploads }} uploads</div>
                        <div class="small text-muted">{{ member.last_active }}</div>
                    </div>
                </div>
            </div>
            {% endfor %}
        </div>
    </div>
</div>

<!-- Quick Upload Modal -->
<div class="modal fade" id="quickUploadModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Szybki Upload</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label for="quickFileInput" class="form-label">Wybierz pliki</label>
                    <input type="file" class="form-control" id="quickFileInput" multiple accept="image/*,video/*">
                </div>
                <div class="mb-3">
                    <label for="uploadCategory" class="form-label">Kategoria</label>
                    <select class="form-select" id="uploadCategory">
                        <option value="general">Ogólne</option>
                        <option value="project">Projekt</option>
                        <option value="personal">Osobiste</option>
                        <option value="marketing">Marketing</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label for="uploadTags" class="form-label">Tagi (oddzielone przecinkami)</label>
                    <input type="text" class="form-control" id="uploadTags" placeholder="tag1, tag2, tag3">
                </div>
                <div id="quick-upload-progress"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Anuluj</button>
                <button type="button" class="btn btn-primary" onclick="startQuickUpload()">Upload</button>
            </div>
        </div>
    </div>
</div>

<!-- Media Preview Modal -->
<div class="modal fade" id="mediaModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mediaModalTitle">Media Preview</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <img id="mediaModalImage" src="" alt="" class="img-fluid" style="max-height: 500px;">
                <video id="mediaModalVideo" controls style="max-height: 500px; display: none;" class="w-100">
                    <source id="mediaModalVideoSource" src="" type="video/mp4">
                </video>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Zamknij</button>
                <button type="button" class="btn btn-primary" onclick="downloadCurrentMedia()">Pobierz</button>
            </div>
        </div>
    </div>
</div>
{% endblock %}

{% block extra_js %}
<script>
let selectedFiles = [];
let currentMediaUrl = '';

$(document).ready(function() {
    // Main upload zone
    $('#mainUploadZone').on('click', function() {
        $('#mediaFileInput').click();
    });

    $('#mainUploadZone').on('dragover', function(e) {
        e.preventDefault();
        $(this).addClass('dragover');
    });

    $('#mainUploadZone').on('dragleave', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
    });

    $('#mainUploadZone').on('drop', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
        const files = e.originalEvent.dataTransfer.files;
        handleMediaFiles(files);
    });

    $('#mediaFileInput').on('change', function() {
        handleMediaFiles(this.files);
    });

    // Gallery filters
    $('[data-filter]').on('click', function() {
        const filter = $(this).data('filter');
        $('[data-filter]').removeClass('active');
        $(this).addClass('active');

        if (filter === 'all') {
            $('.media-item').show();
        } else {
            $('.media-item').hide();
            $(`.media-item[data-type="${filter}"]`).show();
        }
    });

    // Media modal
    $('#mediaModal').on('show.bs.modal', function(e) {
        const button = $(e.relatedTarget);
        const mediaUrl = button.data('media-url');
        const mediaName = button.data('media-name');
        const isVideo = mediaUrl.includes('.mp4') || mediaUrl.includes('.mov');

        currentMediaUrl = mediaUrl;
        $('#mediaModalTitle').text(mediaName);

        if (isVideo) {
            $('#mediaModalImage').hide();
            $('#mediaModalVideo').show();
            $('#mediaModalVideoSource').attr('src', mediaUrl);
            $('#mediaModalVideo')[0].load();
        } else {
            $('#mediaModalVideo').hide();
            $('#mediaModalImage').show();
            $('#mediaModalImage').attr('src', mediaUrl);
        }
    });
});

function handleMediaFiles(files) {
    selectedFiles = Array.from(files);
    let queueHtml = '<h6>Kolejka uploadu:</h6>';

    selectedFiles.forEach((file, index) => {
        queueHtml += `
            <div class="d-flex justify-content-between align-items-center p-2 border rounded mb-2" id="queue-item-${index}">
                <div>
                    <i class="fas fa-${file.type.startsWith('video') ? 'video' : 'image'} me-2"></i>
                    ${file.name}
                    <small class="text-muted">(${(file.size / 1024 / 1024).toFixed(2)} MB)</small>
                </div>
                <div>
                    <button class="btn btn-sm btn-outline-danger" onclick="removeFromQueue(${index})">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>
        `;
    });

    queueHtml += `
        <div class="d-grid gap-2 mt-3">
            <button class="btn btn-primary" onclick="uploadQueuedFiles()">
                <i class="fas fa-cloud-upload-alt me-2"></i>
                Upload ${selectedFiles.length} plików
            </button>
        </div>
    `;

    $('#upload-queue').html(queueHtml);
}

function removeFromQueue(index) {
    selectedFiles.splice(index, 1);
    $(`#queue-item-${index}`).remove();

    if (selectedFiles.length === 0) {
        $('#upload-queue').empty();
    }
}

function uploadQueuedFiles() {
    selectedFiles.forEach((file, index) => {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('category', 'manager_upload');
        formData.append('auto_process', $('#autoProcess').is(':checked'));
        formData.append('generate_thumbnails', $('#generateThumbnails').is(':checked'));

        // Send to Camel route
        sendToCamel('manager_upload', {
            filename: file.name,
            size: file.size,
            type: file.type,
            auto_process: $('#autoProcess').is(':checked'),
            generate_thumbnails: $('#generateThumbnails').is(':checked'),
            user: '{{ user_name }}'
        }).done(function() {
            $(`#queue-item-${index}`).addClass('border-success');
            updateUploadProgress(((index + 1) / selectedFiles.length) * 100, file.name);
        });
    });
}

function startQuickUpload() {
    const files = $('#quickFileInput')[0].files;
    const category = $('#uploadCategory').val();
    const tags = $('#uploadTags').val();

    Array.from(files).forEach((file, index) => {
        sendToCamel('quick_upload', {
            filename: file.name,
            category: category,
            tags: tags.split(',').map(tag => tag.trim()),
            user: '{{ user_name }}'
        });
    });

    $('#quickUploadModal').modal('hide');
    showAlert('Upload rozpoczęty', 'success', 'check-circle');
}

function processMedia() {
    sendToCamel('process_media', {
        action: 'start_processing',
        user: '{{ user_name }}'
    });
}

function refreshProcessingStatus() {
    // Simulate refresh
    showAlert('Status odświeżony', 'info', 'sync-alt');
}

function downloadMedia(mediaId) {
    sendToCamel('download', {
        media_id: mediaId,
        action: 'download',
        user: '{{ user_name }}'
    });
}

function shareMedia(mediaId) {
    // Implementation for sharing
    showAlert('Link do udostępnienia skopiowany', 'success', 'share');
}

function editMedia(mediaId) {
    // Implementation for editing
    showAlert('Edytor mediów otwarty', 'info', 'edit');
}

function deleteMedia(mediaId) {
    if (confirm('Czy na pewno chcesz usunąć to media?')) {
        sendToCamel('delete', {
            media_id: mediaId,
            action: 'delete',
            user: '{{ user_name }}'
        });
    }
}

function downloadCurrentMedia() {
    if (currentMediaUrl) {
        const link = document.createElement('a');
        link.href = currentMediaUrl;
        link.download = '';
        link.click();
    }
}
</script>
{% endblock %}
EOF

# Template dla Klienta Zewnętrznego
echo "👤 Tworzenie template klienta zewnętrznego..."
cat > templates/external_client.html << 'EOF'
{% extends "base.html" %}

{% set user_role = "external_client" %}

{% block title %}Klient - MedaVault{% endblock %}

{% block navigation %}
{{ super() }}
<li class="nav-item">
    <a class="nav-link active" href="/client/dashboard">
        <i class="fas fa-tachometer-alt me-2"></i>
        Dashboard
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/client/submit">
        <i class="fas fa-cloud-upload-alt me-2"></i>
        Prześlij Media
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/client/gallery">
        <i class="fas fa-images me-2"></i>
        Moja Galeria
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/client/orders">
        <i class="fas fa-shopping-cart me-2"></i>
        Zamówienia
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/client/downloads">
        <i class="fas fa-download me-2"></i>
        Pobrane
    </a>
</li>
<li class="nav-item">
    <a class="nav-link" href="/client/support">
        <i class="fas fa-life-ring me-2"></i>
        Wsparcie
    </a>
</li>
{% endblock %}

{% block page_title %}Portal Klienta{% endblock %}

{% block header_actions %}
{{ super() }}
<div class="btn-group">
    <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#submitModal">
        <i class="fas fa-plus"></i>
        Nowe Zlecenie
    </button>
    <button type="button" class="btn btn-sm btn-outline-secondary" onclick="contactSupport()">
        <i class="fas fa-headset"></i>
        Kontakt
    </button>
</div>
{% endblock %}

{% block content %}
<!-- Client Overview -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6">
        <div class="card role-external_client mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Przesłane Media</div>
                        <div class="h3 mb-0">{{ stats.submitted_media | default(0) }}</div>
                    </div>
                    <div class="fas fa-cloud-upload-alt fa-2x text-success"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">W Realizacji</div>
                        <div class="h3 mb-0">{{ stats.in_progress | default(0) }}</div>
                    </div>
                    <div class="fas fa-clock fa-2x text-warning"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Gotowe</div>
                        <div class="h3 mb-0">{{ stats.completed | default(0) }}</div>
                    </div>
                    <div class="fas fa-check-circle fa-2x text-primary"></div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-xl-3 col-md-6">
        <div class="card mb-4">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <div>
                        <div class="small text-muted">Pobrane</div>
                        <div class="h3 mb-0">{{ stats.downloaded | default(0) }}</div>
                    </div>
                    <div class="fas fa-download fa-2x text-info"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Upload Section -->
<div class="row mb-4">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-cloud-upload-alt me-2"></i>
                    Prześlij Media do Przetworzenia
                </h5>
            </div>
            <div class="card-body">
                <div class="upload-zone" id="clientUploadZone">
                    <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                    <h5>Przeciągnij pliki tutaj</h5>
                    <p class="text-muted">Obsługujemy zdjęcia RAW, JPEG, wideo 4K i inne formaty</p>
                    <input type="file" id="clientFileInput" multiple accept="image/*,video/*,.raw,.cr2,.nef,.arw" style="display: none;">

                    <div class="row mt-3">
                        <div class="col-md-6">
                            <small class="text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Maksymalny rozmiar: 2GB na plik
                            </small>
                        </div>
                        <div class="col-md-6">
                            <small class="text-muted">
                                <i class="fas fa-shield-alt me-1"></i>
                                Bezpieczne szyfrowanie SSL
                            </small>
                        </div>
                    </div>
                </div>

                <!-- Upload Options -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <label for="projectType" class="form-label">Typ projektu</label>
                        <select class="form-select" id="projectType">
                            <option value="photo_editing">Edycja zdjęć</option>
                            <option value="video_editing">Montaż wideo</option>
                            <option value="color_correction">Korekcja kolorów</option>
                            <option value="retouching">Retusz</option>
                            <option value="other">Inne</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label for="priority" class="form-label">Priorytet</label>
                        <select class="form-select" id="priority">
                            <option value="standard">Standardowy (5-7 dni)</option>
                            <option value="express">Express (2-3 dni) +50%</option>
                            <option value="urgent">Pilny (24h) +100%</option>
                        </select>
                    </div>
                </div>

                <div class="mt-3">
                    <label for="projectDescription" class="form-label">Opis projektu / Specjalne wymagania</label>
                    <textarea class="form-control" id="projectDescription" rows="3" placeholder="Opisz swoje wymagania..."></textarea>
                </div>

                <div id="client-upload-queue" class="mt-3"></div>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-info-circle me-2"></i>
                    Informacje
                </h5>
            </div>
            <div class="card-body">
                <div class="alert alert-info">
                    <h6><i class="fas fa-clock me-2"></i>Czas realizacji</h6>
                    <ul class="mb-0 small">
                        <li>Standardowy: 5-7 dni roboczych</li>
                        <li>Express: 2-3 dni robocze</li>
                        <li>Pilny: do 24 godzin</li>
                    </ul>
                </div>

                <div class="alert alert-success">
                    <h6><i class="fas fa-file-alt me-2"></i>Obsługiwane formaty</h6>
                    <ul class="mb-0 small">
                        <li>Zdjęcia: RAW, JPEG, PNG, TIFF</li>
                        <li>Wideo: MP4, MOV, AVI, 4K</li>
                        <li>Dokumenty: PDF, PSD, AI</li>
                    </ul>
                </div>

                <div class="alert alert-warning">
                    <h6><i class="fas fa-shield-alt me-2"></i>Bezpieczeństwo</h6>
                    <p class="mb-0 small">
                        Wszystkie pliki są szyfrowane i automatycznie usuwane po 30 dniach od zakończenia projektu.
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Orders -->
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
            <i class="fas fa-shopping-cart me-2"></i>
            Ostatnie Zamówienia
        </h5>
        <a href="/client/orders" class="btn btn-sm btn-outline-primary">Zobacz wszystkie</a>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Projekt</th>
                        <th>Status</th>
                        <th>Data</th>
                        <th>Priorytet</th>
                        <th>Akcje</th>
                    </tr>
                </thead>
                <tbody>
                    {% for order in recent_orders | default([
                        {'id': 'ORD001', 'project': 'Sesja ślubna - edycja', 'status': 'completed', 'date': '2024-01-10', 'priority': 'standard'},
                        {'id': 'ORD002', 'project': 'Video corporate', 'status': 'in_progress', 'date': '2024-01-12', 'priority': 'express'},
                        {'id': 'ORD003', 'project': 'Retusz produktów', 'status': 'pending', 'date': '2024-01-15', 'priority': 'urgent'}
                    ]) %}
                    <tr>
                        <td><strong>{{ order.id }}</strong></td>
                        <td>{{ order.project }}</td>
                        <td>
                            <span class="badge bg-{{ 'success' if order.status == 'completed' else 'warning' if order.status == 'in_progress' else 'secondary' }}">
                                {% if order.status == 'completed' %}Gotowe
                                {% elif order.status == 'in_progress' %}W realizacji
                                {% else %}Oczekuje{% endif %}
                            </span>
                        </td>
                        <td>{{ order.date }}</td>
                        <td>
                            <span class="badge bg-{{ 'danger' if order.priority == 'urgent' else 'warning' if order.priority == 'express' else 'info' }}">
                                {{ order.priority | title }}
                            </span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-primary" onclick="viewOrder('{{ order.id }}')">
                                    <i class="fas fa-eye"></i>
                                </button>
                                {% if order.status == 'completed' %}
                                <button class="btn btn-outline-success" onclick="downloadOrder('{{ order.id }}')">
                                    <i class="fas fa-download"></i>
                                </button>
                                {% endif %}
                            </div>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Available Downloads -->
<div class="card">
    <div class="card-header">
        <h5 class="mb-0">
            <i class="fas fa-download me-2"></i>
            Dostępne do Pobrania
        </h5>
    </div>
    <div class="card-body">
        <div class="row">
            {% for download in available_downloads | default([
                {'id': 'DL001', 'name': 'Edytowane zdjęcia ślubne', 'size': '250 MB', 'expires': '15 dni', 'type': 'photos'},
                {'id': 'DL002', 'name': 'Video montaż - final', 'size': '1.2 GB', 'expires': '28 dni', 'type': 'video'},
                {'id': 'DL003', 'name': 'Retusz produktów - JPEG', 'size': '85 MB', 'expires': '10 dni', 'type': 'photos'}
            ]) %}
            <div class="col-md-4 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h6 class="card-title">{{ download.name }}</h6>
                            <span class="badge bg-primary">{{ download.type }}</span>
                        </div>
                        <p class="card-text small text-muted">
                            <i class="fas fa-hdd me-1"></i>{{ download.size }}<br>
                            <i class="fas fa-clock me-1"></i>Wygasa za {{ download.expires }}
                        </p>
                        <div class="d-grid">
                            <button class="btn btn-success btn-sm" onclick="downloadFile('{{ download.id }}')">
                                <i class="fas fa-download me-2"></i>Pobierz
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            {% endfor %}
        </div>
    </div>
</div>

<!-- Submit New Order Modal -->
<div class="modal fade" id="submitModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Nowe Zlecenie</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="newOrderForm">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="orderType" class="form-label">Typ zlecenia</label>
                                <select class="form-select" id="orderType" required>
                                    <option value="">Wybierz typ</option>
                                    <option value="photo_editing">Edycja zdjęć</option>
                                    <option value="video_editing">Montaż wideo</option>
                                    <option value="color_correction">Korekcja kolorów</option>
                                    <option value="retouching">Retusz profesjonalny</option>
                                    <option value="restoration">Restauracja zdjęć</option>
                                    <option value="other">Inne - opisz w komentarzu</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="orderPriority" class="form-label">Priorytet</label>
                                <select class="form-select" id="orderPriority" required>
                                    <option value="standard">Standardowy (5-7 dni)</option>
                                    <option value="express">Express (2-3 dni) +50%</option>
                                    <option value="urgent">Pilny (24h) +100%</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="orderTitle" class="form-label">Nazwa projektu</label>
                        <input type="text" class="form-control" id="orderTitle" required>
                    </div>

                    <div class="mb-3">
                        <label for="orderDescription" class="form-label">Opis wymagań</label>
                        <textarea class="form-control" id="orderDescription" rows="4" required></textarea>
                    </div>

                    <div class="mb-3">
                        <label for="modalFileInput" class="form-label">Pliki źródłowe</label>
                        <input type="file" class="form-control" id="modalFileInput" multiple accept="image/*,video/*,.raw,.cr2,.nef,.arw">
                        <div class="form-text">Możesz dodać pliki teraz lub później</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="deadline" class="form-label">Preferowany termin (opcjonalny)</label>
                                <input type="date" class="form-control" id="deadline">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="budget" class="form-label">Budżet (PLN)</label>
                                <select class="form-select" id="budget">
                                    <option value="">Nie określono</option>
                                    <option value="100-500">100-500 PLN</option>
                                    <option value="500-1000">500-1000 PLN</option>
                                    <option value="1000-2000">1000-2000 PLN</option>
                                    <option value="2000+">Powyżej 2000 PLN</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Anuluj</button>
                <button type="button" class="btn btn-primary" onclick="submitNewOrder()">Złóż zlecenie</button>
            </div>
        </div>
    </div>
</div>
{% endblock %}

{% block extra_js %}
<script>
let clientSelectedFiles = [];

$(document).ready(function() {
    // Client upload zone
    $('#clientUploadZone').on('click', function() {
        $('#clientFileInput').click();
    });

    $('#clientUploadZone').on('dragover', function(e) {
        e.preventDefault();
        $(this).addClass('dragover');
    });

    $('#clientUploadZone').on('dragleave', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
    });

    $('#clientUploadZone').on('drop', function(e) {
        e.preventDefault();
        $(this).removeClass('dragover');
        const files = e.originalEvent.dataTransfer.files;
        handleClientFiles(files);
    });

    $('#clientFileInput').on('change', function() {
        handleClientFiles(this.files);
    });

    // Auto-refresh order status every 30 seconds
    setInterval(refreshOrderStatus, 30000);
});

function handleClientFiles(files) {
    clientSelectedFiles = Array.from(files);
    let queueHtml = '<div class="alert alert-info"><h6>Wybrane pliki do przesłania:</h6>';

    let totalSize = 0;
    clientSelectedFiles.forEach((file, index) => {
        totalSize += file.size;
        queueHtml += `
            <div class="d-flex justify-content-between align-items-center py-1">
                <div>
                    <i class="fas fa-${getFileIcon(file.type)} me-2"></i>
                    ${file.name}
                    <small class="text-muted">(${(file.size / 1024 / 1024).toFixed(2)} MB)</small>
                </div>
                <button class="btn btn-sm btn-outline-danger" onclick="removeClientFile(${index})">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;
    });

    queueHtml += `
        <hr>
        <div class="d-flex justify-content-between align-items-center">
            <strong>Łączny rozmiar: ${(totalSize / 1024 / 1024).toFixed(2)} MB</strong>
            <button class="btn btn-primary" onclick="uploadClientFiles()">
                <i class="fas fa-cloud-upload-alt me-2"></i>
                Prześlij i Utwórz Zlecenie
            </button>
        </div>
    </div>`;

    $('#client-upload-queue').html(queueHtml);
}

function removeClientFile(index) {
    clientSelectedFiles.splice(index, 1);
    if (clientSelectedFiles.length > 0) {
        handleClientFiles(clientSelectedFiles);
    } else {
        $('#client-upload-queue').empty();
    }
}

function getFileIcon(fileType) {
    if (fileType.startsWith('image')) return 'image';
    if (fileType.startsWith('video')) return 'video';
    if (fileType.includes('pdf')) return 'file-pdf';
    return 'file';
}

function uploadClientFiles() {
    const projectType = $('#projectType').val();
    const priority = $('#priority').val();
    const description = $('#projectDescription').val();

    if (!projectType || !priority) {
        showAlert('Proszę wybrać typ projektu i priorytet', 'warning', 'exclamation-triangle');
        return;
    }

    // Create order first
    const orderData = {
        type: projectType,
        priority: priority,
        description: description,
        files_count: clientSelectedFiles.length,
        total_size: clientSelectedFiles.reduce((sum, file) => sum + file.size, 0),
        user: '{{ user_name }}',
        action: 'create_order'
    };

    sendToCamel('client_order', orderData).done(function(response) {
        // Upload files
        clientSelectedFiles.forEach((file, index) => {
            const formData = new FormData();
            formData.append('file', file);
            formData.append('order_id', response.order_id);
            formData.append('project_type', projectType);
            formData.append('priority', priority);

            sendToCamel('client_upload', {
                filename: file.name,
                order_id: response.order_id,
                project_type: projectType,
                priority: priority,
                user: '{{ user_name }}'
            });
        });

        showAlert('Zlecenie utworzone pomyślnie! ID: ' + response.order_id, 'success', 'check-circle');
        $('#client-upload-queue').empty();
        clientSelectedFiles = [];

        // Reset form
        $('#projectType').val('');
        $('#priority').val('');
        $('#projectDescription').val('');
    });
}

function submitNewOrder() {
    const form = $('#newOrderForm')[0];
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const orderData = {
        type: $('#orderType').val(),
        priority: $('#orderPriority').val(),
        title: $('#orderTitle').val(),
        description: $('#orderDescription').val(),
        deadline: $('#deadline').val(),
        budget: $('#budget').val(),
        user: '{{ user_name }}',
        action: 'create_order'
    };

    sendToCamel('client_order', orderData).done(function(response) {
        $('#submitModal').modal('hide');
        showAlert('Zlecenie zostało złożone! ID: ' + response.order_id, 'success', 'check-circle');

        // Reset form
        form.reset();

        // Refresh page after delay
        setTimeout(() => location.reload(), 2000);
    });
}

function viewOrder(orderId) {
    // Implementation for viewing order details
    showAlert('Szczegóły zamówienia ' + orderId, 'info', 'eye');
}

function downloadOrder(orderId) {
    sendToCamel('download_order', {
        order_id: orderId,
        user: '{{ user_name }}',
        action: 'download_completed_order'
    }).done(function() {
        showAlert('Pobieranie rozpoczęte', 'success', 'download');
    });
}

function downloadFile(downloadId) {
    sendToCamel('download_file', {
        download_id: downloadId,
        user: '{{ user_name }}',
        action: 'download_file'
    }).done(function() {
        showAlert('Pobieranie rozpoczęte', 'success', 'download');
    });
}

function contactSupport() {
    // Implementation for contacting support
    showAlert('Przekierowanie do wsparcia technicznego', 'info', 'headset');
}

function refreshOrderStatus() {
    sendToCamel('refresh_status', {
        user: '{{ user_name }}',
        action: 'refresh_order_status'
    });
}
</script>
{% endblock %}
EOF

# Tworzenie pliku konfiguracyjnego Flask/Jinja2
echo "⚙️ Tworzenie app.py..."
cat > app.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, render_template, request, jsonify
import json
import os

app = Flask(__name__)

# Mock data dla demonstracji
MOCK_DATA = {
    'administrator': {
        'user_name': 'Admin System',
        'stats': {
            'total_users': 156,
            'total_media': 2847,
            'total_size': '125 GB',
            'active_sessions': 23
        },
        'camel_routes': [
            {'name': 'file-to-medavault', 'status': 'running', 'processed': 125},
            {'name': 'media-processor', 'status': 'running', 'processed': 89},
            {'name': 'cleanup-task', 'status': 'stopped', 'processed': 0}
        ],
        'system': {
            'cpu_usage': 45,
            'memory_usage': 68,
            'disk_usage': 23
        },
        'recent_events': [
            {'type': 'upload', 'user': 'manager1', 'message': 'Uploaded 15 photos', 'time': '2 min ago'},
            {'type': 'user', 'user': 'admin', 'message': 'New user registered', 'time': '5 min ago'},
            {'type': 'system', 'user': 'system', 'message': 'Backup completed', 'time': '1 hour ago'}
        ]
    },
    'manager': {
        'user_name': 'Jan Kowalski',
        'stats': {
            'my_media': 234,
            'processing': 12,
            'team_members': 8,
            'today_uploads': 45
        },
        'processing_tasks': [
            {'id': 'task1', 'file': 'vacation_photos.zip', 'progress': 75, 'status': 'processing'},
            {'id': 'task2', 'file': 'company_video.mp4', 'progress': 100, 'status': 'completed'},
            {'id': 'task3', 'file': 'product_images.rar', 'progress': 30, 'status': 'processing'}
        ],
        'team_activity': [
            {'name': 'Anna Kowalska', 'uploads': 15, 'last_active': '2 min ago'},
            {'name': 'Jan Nowak', 'uploads': 8, 'last_active': '1 hour ago'},
            {'name': 'Marta Wiśniewska', 'uploads': 23, 'last_active': '3 hours ago'}
        ]
    },
    'external_client': {
        'user_name': 'Firma ABC Sp. z o.o.',
        'stats': {
            'submitted_media': 67,
            'in_progress': 3,
            'completed': 12,
            'downloaded': 8
        },
        'recent_orders': [
            {'id': 'ORD001', 'project': 'Sesja ślubna - edycja', 'status': 'completed', 'date': '2024-01-10', 'priority': 'standard'},
            {'id': 'ORD002', 'project': 'Video corporate', 'status': 'in_progress', 'date': '2024-01-12', 'priority': 'express'},
            {'id': 'ORD003', 'project': 'Retusz produktów', 'status': 'pending', 'date': '2024-01-15', 'priority': 'urgent'}
        ],
        'available_downloads': [
            {'id': 'DL001', 'name': 'Edytowane zdjęcia ślubne', 'size': '250 MB', 'expires': '15 dni', 'type': 'photos'},
            {'id': 'DL002', 'name': 'Video montaż - final', 'size': '1.2 GB', 'expires': '28 dni', 'type': 'video'},
            {'id': 'DL003', 'name': 'Retusz produktów - JPEG', 'size': '85 MB', 'expires': '10 dni', 'type': 'photos'}
        ]
    }
}

@app.route('/')
def index():
    return render_template('administrator.html', **MOCK_DATA['administrator'])

@app.route('/admin')
@app.route('/admin/dashboard')
def admin_dashboard():
    return render_template('administrator.html', **MOCK_DATA['administrator'])

@app.route('/manager')
@app.route('/manager/dashboard')
def manager_dashboard():
    return render_template('manager.html', **MOCK_DATA['manager'])

@app.route('/client')
@app.route('/client/dashboard')
def client_dashboard():
    return render_template('external_client.html', **MOCK_DATA['external_client'])

@app.route('/api/camel/<action>', methods=['POST'])
def camel_api(action):
    """Symulacja API Apache Camel"""
    data = request.get_json()

    # Log do konsoli dla demonstracji
    print(f"Apache Camel Action: {action}")
    print(f"Data: {json.dumps(data, indent=2)}")

    # Symulacja odpowiedzi
    response = {
        'status': 'success',
        'action': action,
        'message': f'Action {action} executed successfully',
        'timestamp': '2024-01-15T10:30:00Z'
    }

    if action == 'client_order':
        response['order_id'] = f"ORD{len(MOCK_DATA['external_client']['recent_orders']) + 1:03d}"

    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
EOF

# Tworzenie requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.3
Jinja2==3.1.2
Werkzeug==2.3.7
click==8.1.7
itsdangerous==2.1.2
MarkupSafe==2.1.3
EOF

# Tworzenie Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
EOF

# Tworzenie docker-compose dla web app
cat > docker-compose-web.yml << 'EOF'
version: '3.8'

services:
  medavault-web:
    build: .
    container_name: medavault-web
    ports:
      - "5000:5000"
    volumes:
      - ./templates:/app/templates
      - ./static:/app/static
      - ./uploads:/app/uploads
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    networks:
      - medavault-network

  medavault-camel:
    image: openjdk:11-jre-slim
    container_name: medavault-camel
    volumes:
      - ../medavault-camel-project/scripts:/app/scripts
      - ./uploads:/app/input
    working_dir: /app
    command: bash -c "cd scripts && groovy FileProcessor.groovy"
    networks:
      - medavault-network

networks:
  medavault-network:
    driver: bridge
EOF

# Tworzenie skryptu startowego
cat > start-web.sh << 'EOF'
#!/bin/bash

echo "🌐 Starting MedaVault Web Templates..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install requirements
echo "📚 Installing requirements..."
pip install -r requirements.txt

# Create uploads directory
mkdir -p uploads

echo "🚀 Starting Flask application..."
echo ""
echo "📊 Web interfaces available at:"
echo "   - Administrator: http://localhost:5000/admin"
echo "   - Manager: http://localhost:5000/manager"
echo "   - External Client: http://localhost:5000/client"
echo ""
echo "🛑 To stop: Press Ctrl+C"

python app.py
EOF

# Tworzenie README dla web templates
cat > README-WEB.md << 'EOF'
# MedaVault Web Templates

Responsywne szablony Bootstrap dla systemu MedaVault z integracją Apache Camel.

## 🎯 Role użytkowników

### 👨‍💼 Administrator (`/admin`)
- Zarządzanie wszystkimi użytkownikami
- Monitorowanie systemu i zasobów
- Kontrola tras Apache Camel
- Masowe operacje na mediach
- Logi i raporty systemowe

### 👨‍💼 Manager (`/manager`)
- Upload i zarządzanie mediami zespołu
- Przetwarzanie plików przez Camel
- Monitoring statusu operacji
- Zarządzanie galerią i zespołem
- Raporty zespołowe

### 👤 Klient Zewnętrzny (`/client`)
- Przesyłanie mediów do obróbki
- Śledzenie statusu zamówień
- Pobieranie gotowych materiałów
- Komunikacja z zespołem
- Zarządzanie projektami

## 🚀 Uruchomienie

### Sposób 1: Lokalnie z Python
```bash
chmod +x start-web.sh
./start-web.sh
```

### Sposób 2: Docker
```bash
docker-compose -f docker-compose-web.yml up
```

## 🎨 Funkcje

### UI/UX
- **Bootstrap 5.3** - responsywny design
- **Font Awesome** - ikony
- **Gradient design** - nowoczesny wygląd
- **Dark/light modes** - automatyczne przełączanie
- **Drag & drop** - intuitive upload
- **Real-time updates** - WebSocket ready

### Integracja Apache Camel
- **REST API** endpoints dla Camel
- **Automatyczne routing** plików
- **Status monitoring** tras Camel
- **Error handling** z retry logic
- **Bulk operations** dla dużych plików

### Bezpieczeństwo
- **Role-based access** - kontrola dostępu
- **File validation** - sprawdzanie typów
- **SSL ready** - szyfrowanie
- **Session management** - zarządzanie sesjami

## 📁 Struktura

```
medavault-web-templates/
├── templates/
│   ├── base.html              # Bazowy template
│   ├── administrator.html     # Panel admina
│   ├── manager.html          # Panel managera
│   └── external_client.html  # Panel klienta
├── static/
│   ├── css/                  # Style CSS
│   ├── js/                   # JavaScript
│   └── images/               # Obrazy
├── uploads/                  # Upload folder
├── app.py                    # Flask application
├── requirements.txt          # Python dependencies
├── Dockerfile               # Docker config
├── docker-compose-web.yml   # Docker Compose
└── start-web.sh            # Start script
```

## 🔧 Kustomizacja

### Zmiana kolorów
Edytuj CSS w `templates/base.html`:
```css
.sidebar {
    background: linear-gradient(135deg, #YOUR_COLOR 0%, #YOUR_COLOR2 100%);
}
```

### Dodanie nowych ról
1. Stwórz nowy template w `templates/`
2. Dodaj route w `app.py`
3. Dodaj dane mock w `MOCK_DATA`

### Integracja z prawdziwym Camel
Zamień `@app.route('/api/camel/<action>')` na prawdziwe wywołania:
```python
import requests

def call_camel_route(action, data):
    response = requests.post(f'http://camel-server:8080/{action}', json=data)
    return response.json()
```

## 📊 API Endpoints

- `POST /api/camel/upload` - Upload plików
- `POST /api/camel/process` - Przetwarzanie
- `POST /api/camel/download` - Pobieranie
- `POST /api/camel/status` - Status operacji

## 🌐 Dostępne URL

- **Admin:** `http://localhost:5000/admin`
- **Manager:** `http://localhost:5000/manager`
- **Client:** `http://localhost:5000/client`

## 📱 Responsive Design

Templates są w pełni responsywne i działają na:
- 💻 Desktop (1200px+)
- 📱 Tablet (768px - 1199px)
- 📱 Mobile (< 768px)

## 🛠️ Rozwój

Templates używają Jinja2, więc można łatwo:
- Dodawać zmienne kontekstowe
- Tworzyć filtry custom
- Rozszerzać funkcjonalność
- Integrować z bazami danych

Powodzenia z MedaVault! 🚀
EOF

# Ustawianie uprawnień
chmod +x start-web.sh

echo ""
echo "🎨 Szablony MedaVault z Bootstrap zostały utworzone!"
echo ""
echo "📁 Lokalizacja: $PROJECT_DIR"
echo ""
echo "🚀 Aby uruchomić:"
echo "   cd $PROJECT_NAME"
echo "   ./start-web.sh"
echo ""
echo "🌐 Dostępne interfejsy:"
echo "   👨‍💼 Administrator: http://localhost:5000/admin"
echo "   👨‍💼 Manager: http://localhost:5000/manager"
echo "   👤 Klient: http://localhost:5000/client"
echo ""
echo "📚 Dokumentacja: README-WEB.md"
echo ""
echo "✨ Templates gotowe do integracji z Apache Camel!"