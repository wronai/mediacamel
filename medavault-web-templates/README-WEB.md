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
