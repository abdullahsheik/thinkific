.PHONY: help build up down logs clean ssl-certs test db-setup db-reset

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build all Docker images
	docker compose build

up: ## Start all services
	docker compose up -d

down: ## Stop all services
	docker compose down

logs: ## Show logs for all services
	docker compose logs -f

clean: ## Remove all containers, networks, and volumes
	docker compose down -v --remove-orphans
	docker system prune -f

ssl-certs: ## Generate SSL certificates
	mkdir -p nginx/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout nginx/ssl/server.key \
		-out nginx/ssl/server.crt \
		-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

auth: ## Create authentication file
	mkdir -p nginx/auth
	htpasswd -cb nginx/auth/.htpasswd admin admin123

setup: ssl-certs auth ## Initial setup (SSL + auth)
	@echo "Setup complete!"

test: ## Run tests
	docker compose exec rails-app bundle exec rspec

db-setup: ## Setup database
	docker compose exec rails-app bundle exec rails db:setup

db-migrate: ## Run database migrations
	docker compose exec rails-app bundle exec rails db:migrate

db-reset: ## Reset database
	docker compose exec rails-app bundle exec rails db:reset

console: ## Start Rails console
	docker compose exec rails-app bundle exec rails console

health: ## Check application health
	curl -k https://localhost/health

metrics: ## Get application metrics
	curl -k https://localhost/metrics

prometheus: ## Open Prometheus in browser
	open http://localhost:9090

grafana: ## Open Grafana in browser
	open http://localhost:3001

restart: down up ## Restart all services

rebuild: clean build up ## Clean rebuild and start

status: ## Show service status
	docker compose ps

monitor: ## Monitor all services
	watch -n 2 'docker compose ps'

backup: ## Backup database
	docker compose exec postgres pg_dump -U postgres autoincrement_dev > backup_$(shell date +%Y%m%d_%H%M%S).sql

restore: ## Restore database (usage: make restore FILE=backup_file.sql)
	docker compose exec -T postgres psql -U postgres autoincrement_dev < $(FILE)
