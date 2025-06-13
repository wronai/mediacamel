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
