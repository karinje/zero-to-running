.PHONY: help dev down clean restart logs logs-frontend logs-backend logs-db logs-redis health ps shell-frontend shell-backend shell-db shell-redis db-seed db-reset db-backup db-restore lint test check-docker

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

dev: check-docker ## Start all services
	@echo "$(GREEN)Starting all services...$(NC)"
	@docker-compose -f $(COMPOSE_FILE) up -d
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

##@ Utilities

lint: ## Run linters on all code
	@echo "$(YELLOW)Linting not yet implemented$(NC)"
	@echo "$(BLUE)This will be added in PR-013$(NC)"

test: ## Run all tests
	@echo "$(YELLOW)Testing not yet implemented$(NC)"
	@echo "$(BLUE)This will be added in PR-016$(NC)"

check-docker: ## Check if Docker is installed and running
	@./scripts/check-docker.sh

help: ## Display this help message
	@echo "$(BLUE)Zero-to-Running Developer Environment$(NC)"
	@echo "$(BLUE)=====================================$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)For more information, see README.md$(NC)"

