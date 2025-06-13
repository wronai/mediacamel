.PHONY: help setup build up down restart logs clean test-upload test-webdav test-api

# Default target
help:
	@echo "\n\033[1mMedaCamel - Media Management System\033[0m"
	@echo "\n\033[1mUsage:\033[0m"
	@echo "  make <target>"
	@echo ""
	@echo "\033[1mTargets:\033[0m"
	@echo "  \033[32msetup\033[0m          - Setup the project environment"
	@echo "  \033[32mbuild\033[0m          - Build all Docker containers"
	@echo "  \033[32mup\033[0m            - Start all services in detached mode"
	@echo "  \033[32mdown\033[0m          - Stop and remove all containers"
	@echo "  \033[32mrestart\033[0m       - Restart all services"
	@echo "  \033[32mlogs\033[0m           - Show logs for all services"
	@echo "  \033[32mclean\033[0m          - Remove all containers, networks, and volumes"
	@echo "  \033[32mtest-upload\033[0m    - Test file upload to WebDAV"
	@echo "  \033[32mtest-webdav\033[0m    - Test WebDAV connection"
	@echo "  \033[32mtest-api\033[0m       - Test API endpoints"
	@echo "  \033[32mstatus\033[0m         - Show service status"

# Environment setup
setup:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Created .env file from .env.example"; \
	else \
		echo ".env file already exists"; \
	fi
	@mkdir -p storage processed logs
	@chmod +x scripts/*.sh

# Docker Compose commands
build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

clean:
	docker-compose down -v --remove-orphans

test-upload:
	@if [ -f scripts/test-upload.sh ]; then \
		./scripts/test-upload.sh; \
	else \
		echo "test-upload.sh not found in scripts directory"; \
	fi

test-webdav:
	@curl -v -X PROPFIND http://localhost:8081/ -u "$(shell grep WEBDAV_USER .env | cut -d '=' -f2):$(shell grep WEBDAV_PASSWORD .env | cut -d '=' -f2)" -H "Depth: 1"

test-api:
	@curl -v http://localhost:8084/health

status:
	@echo "\n\033[1mService Status:\033[0m"
	@echo "--------------"
	@echo "WebDAV:     http://localhost:8081/"
	@echo "Filestash:  http://localhost:8082/"
	@echo "API:        http://localhost:8084/health"
	@echo "Dashboard:  http://localhost:8085/"
	@echo ""
	@echo "WebDAV Credentials:"
	@echo "  Username: $(shell grep WEBDAV_USER .env | cut -d '=' -f2)"
	@echo "  Password: $(shell grep WEBDAV_PASSWORD .env | cut -d '=' -f2)"

# Include any additional makefiles
-include Makefile.local
