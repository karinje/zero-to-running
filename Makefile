.PHONY: help dev down clean restart logs logs-frontend logs-backend logs-db logs-redis logs-filter logs-aggregate health ps shell-frontend shell-backend shell-db shell-redis db-seed db-reset db-backup db-restore db-migrate db-rollback lint lint-fix format test test-backend test-frontend check-docker pre-flight validate-env check-ports troubleshoot prune rebuild rebuild-backend rebuild-frontend update up stop

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
BLUE   := \033[0;34m
NC     := \033[0m # No Color

# Project name
PROJECT_NAME := wander
COMPOSE_FILE := docker-compose.yml

# Default target
.DEFAULT_GOAL := help

##@ Primary Commands

dev: pre-flight ## Start all services
	@echo "$(GREEN)Starting all services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d || (echo "$(RED)❌ Failed to start services$(NC)" && exit 1)
	@echo "$(GREEN)✓ Services started!$(NC)"
	@echo "$(BLUE)Frontend: http://localhost:3000$(NC)"
	@echo "$(BLUE)Backend:  http://localhost:4000$(NC)"
	@echo "$(BLUE)Postgres: localhost:5432$(NC)"
	@echo "$(BLUE)Redis:    localhost:6379$(NC)"

down: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Services stopped$(NC)"

clean: ## Remove all data and volumes
	@echo "$(RED)⚠ This will remove all data and volumes!$(NC)"
	@echo -n "Are you sure? [y/N] "; \
	read REPLY; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		echo "$(YELLOW)Removing containers, volumes, and data...$(NC)"; \
		docker-compose -f $(COMPOSE_FILE) down -v; \
		docker system prune -f; \
		echo "$(GREEN)✓ Cleanup complete$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

restart: ## Restart all services
	@echo "$(YELLOW)Restarting all services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

##@ Monitoring

logs: ## View all service logs
	@docker-compose -f $(COMPOSE_FILE) logs -f

logs-frontend: ## View frontend logs only
	@docker-compose -f $(COMPOSE_FILE) logs -f frontend

logs-backend: ## View backend logs only
	@docker-compose -f $(COMPOSE_FILE) logs -f backend

logs-db: ## View database logs only
	@docker-compose -f $(COMPOSE_FILE) logs -f postgres

logs-redis: ## View redis logs only
	@docker-compose -f $(COMPOSE_FILE) logs -f redis

logs-filter: ## Filter logs by level or service (usage: make logs-filter LEVEL=error or make logs-filter SERVICE=backend)
	@if [ -z "$(LEVEL)" ] && [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Error: LEVEL or SERVICE parameter required$(NC)"; \
		echo "$(YELLOW)Usage: make logs-filter LEVEL=error$(NC)"; \
		echo "$(YELLOW)       make logs-filter SERVICE=backend$(NC)"; \
		exit 1; \
	fi
	@if [ ! -z "$(LEVEL)" ]; then \
		./scripts/logs-filter.sh level $(LEVEL); \
	elif [ ! -z "$(SERVICE)" ]; then \
		./scripts/logs-filter.sh service $(SERVICE); \
	fi

logs-aggregate: ## Aggregate logs from all services with timestamps
	@./scripts/logs-aggregate.sh

health: ## Check all service health
	@./scripts/health-check.sh

ps: ## Show running containers
	@echo "$(BLUE)Running containers:$(NC)"
	@docker-compose -f $(COMPOSE_FILE) ps

##@ Development

shell-frontend: ## Access frontend container shell
	@docker-compose -f $(COMPOSE_FILE) exec frontend sh

shell-backend: ## Access backend container shell
	@docker-compose -f $(COMPOSE_FILE) exec backend sh

shell-db: ## Access postgres shell
	@docker-compose -f $(COMPOSE_FILE) exec postgres psql -U $$(grep POSTGRES_USER .env 2>/dev/null | cut -d '=' -f2 || echo "wander_user") -d $$(grep POSTGRES_DB .env 2>/dev/null | cut -d '=' -f2 || echo "wander_dev")

shell-redis: ## Access redis-cli
	@docker-compose -f $(COMPOSE_FILE) exec redis redis-cli -a $$(grep REDIS_PASSWORD .env 2>/dev/null | cut -d '=' -f2 || echo "dev_redis_password")

##@ Database

db-seed: ## Seed database with sample data
	@echo "$(YELLOW)Seeding database with sample data...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) exec -T backend npm run seed
	@echo "$(GREEN)✓ Database seeded successfully$(NC)"

db-reset: ## Drop and recreate database
	@echo "$(RED)⚠ This will drop and recreate the database!$(NC)"
	@echo -n "Are you sure? [y/N] "; \
	read REPLY; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		echo "$(YELLOW)Resetting database...$(NC)"; \
		docker-compose -f $(COMPOSE_FILE) exec -T postgres psql -U $$(grep POSTGRES_USER .env 2>/dev/null | cut -d '=' -f2 || echo "wander_user") -d postgres -c "DROP DATABASE IF EXISTS $$(grep POSTGRES_DB .env 2>/dev/null | cut -d '=' -f2 || echo "wander_dev");"; \
		docker-compose -f $(COMPOSE_FILE) exec -T postgres psql -U $$(grep POSTGRES_USER .env 2>/dev/null | cut -d '=' -f2 || echo "wander_user") -d postgres -c "CREATE DATABASE $$(grep POSTGRES_DB .env 2>/dev/null | cut -d '=' -f2 || echo "wander_dev");"; \
		echo "$(GREEN)✓ Database reset$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

db-backup: ## Backup database
	@echo "$(YELLOW)Creating database backup...$(NC)"
	@mkdir -p backups
	@docker-compose -f $(COMPOSE_FILE) exec -T postgres pg_dump -U $$(grep POSTGRES_USER .env 2>/dev/null | cut -d '=' -f2 || echo "wander_user") $$(grep POSTGRES_DB .env 2>/dev/null | cut -d '=' -f2 || echo "wander_dev") > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Backup created in backups/$(NC)"

db-restore: ## Restore database from backup (usage: make db-restore FILE=backups/backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: FILE parameter required$(NC)"; \
		echo "$(YELLOW)Usage: make db-restore FILE=backups/backup.sql$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "$(RED)Error: File $(FILE) not found$(NC)"; \
		exit 1; \
	fi
	@echo "$(RED)⚠ This will overwrite the current database!$(NC)"
	@echo -n "Are you sure? [y/N] "; \
	read REPLY; \
	if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		echo "$(YELLOW)Restoring database from $(FILE)...$(NC)"; \
		docker-compose -f $(COMPOSE_FILE) exec -T postgres psql -U $$(grep POSTGRES_USER .env 2>/dev/null | cut -d '=' -f2 || echo "wander_user") -d $$(grep POSTGRES_DB .env 2>/dev/null | cut -d '=' -f2 || echo "wander_dev") < $(FILE); \
		echo "$(GREEN)✓ Database restored$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

db-migrate: ## Run database migrations (placeholder)
	@echo "$(YELLOW)Database migrations will be added when migration system is implemented$(NC)"

db-rollback: ## Rollback last migration (placeholder)
	@echo "$(YELLOW)Database rollback will be added when migration system is implemented$(NC)"

##@ Utilities

##@ Testing

test: ## Run all tests
	@echo "$(YELLOW)Testing framework will be added in PR-016$(NC)"
	@echo "$(BLUE)For now, you can run tests manually:$(NC)"
	@echo "  Backend: docker-compose exec backend npm test"
	@echo "  Frontend: docker-compose exec frontend npm test"

test-backend: ## Run backend tests only
	@echo "$(YELLOW)Backend tests will be added in PR-016$(NC)"

test-frontend: ## Run frontend tests only
	@echo "$(YELLOW)Frontend tests will be added in PR-016$(NC)"

##@ Code Quality

lint: ## Lint all code (backend and frontend)
	@echo "$(YELLOW)Linting all code...$(NC)"
	@./scripts/lint-all.sh

lint-fix: ## Auto-fix linting issues
	@echo "$(YELLOW)Auto-fixing linting issues...$(NC)"
	@docker-compose exec -T backend npm run lint -- --fix || true
	@docker-compose exec -T frontend npm run lint -- --fix || true
	@echo "$(GREEN)✓ Linting fixes applied$(NC)"

format: ## Format all code (placeholder for Prettier)
	@echo "$(YELLOW)Code formatting will be added with Prettier in PR-015$(NC)"

pre-flight: ## Run all pre-flight checks before starting services
	@./scripts/pre-flight.sh

check-docker: ## Check if Docker is installed and running
	@./scripts/check-docker.sh

validate-env: ## Validate environment variables
	@./scripts/validate-env.sh

check-ports: ## Check if required ports are available
	@./scripts/check-ports.sh

##@ Docker Maintenance

prune: ## Clean up unused Docker resources
	@echo "$(YELLOW)Cleaning up unused Docker resources...$(NC)"
	@./scripts/docker-cleanup.sh

rebuild: ## Rebuild all Docker images
	@echo "$(YELLOW)Rebuilding all Docker images...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo "$(GREEN)✓ Images rebuilt$(NC)"

rebuild-backend: ## Rebuild backend image only
	@echo "$(YELLOW)Rebuilding backend image...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build --no-cache backend
	@echo "$(GREEN)✓ Backend image rebuilt$(NC)"

rebuild-frontend: ## Rebuild frontend image only
	@echo "$(YELLOW)Rebuilding frontend image...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) build --no-cache frontend
	@echo "$(GREEN)✓ Frontend image rebuilt$(NC)"

update: ## Update dependencies (rebuild containers)
	@echo "$(YELLOW)Updating dependencies...$(NC)"
	@echo "$(BLUE)Backend:$(NC)"
	@docker-compose exec -T backend npm update || true
	@echo "$(BLUE)Frontend:$(NC)"
	@docker-compose exec -T frontend npm update || true
	@echo "$(GREEN)✓ Dependencies updated$(NC)"
	@echo "$(YELLOW)Note: Rebuild images to use updated dependencies: make rebuild$(NC)"

##@ Shortcuts

up: dev ## Alias for dev

stop: down ## Alias for down

troubleshoot: ## Show troubleshooting information
	@echo "$(BLUE)Troubleshooting Guide$(NC)"
	@echo "$(BLUE)=====================$(NC)"
	@echo ""
	@echo "$(YELLOW)Common issues and solutions:$(NC)"
	@echo ""
	@echo "1. Services won't start:"
	@echo "   $(GREEN)make pre-flight$(NC) - Run all checks"
	@echo "   $(GREEN)make check-ports$(NC) - Check port conflicts"
	@echo ""
	@echo "2. Database connection failed:"
	@echo "   $(GREEN)make validate-env$(NC) - Check environment variables"
	@echo "   $(GREEN)make logs-db$(NC) - View database logs"
	@echo ""
	@echo "3. View logs:"
	@echo "   $(GREEN)make logs$(NC) - All services"
	@echo "   $(GREEN)make logs-filter LEVEL=error$(NC) - Filter by level"
	@echo ""
	@echo "4. Check health:"
	@echo "   $(GREEN)make health$(NC) - All services"
	@echo ""
	@echo "$(YELLOW)For more help:$(NC)"
	@echo "   - See docs/TROUBLESHOOTING.md"
	@echo "   - See docs/FAQ.md"
	@echo "   - See docs/COMMON_ERRORS.md"
	@echo "   - See docs/DEBUGGING.md"

help: ## Display this help message
	@echo "$(BLUE)Zero-to-Running Developer Environment$(NC)"
	@echo "$(BLUE)=====================================$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)For more information, see README.md$(NC)"
	@echo "$(YELLOW)For troubleshooting: make troubleshoot$(NC)"

