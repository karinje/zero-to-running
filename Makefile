.PHONY: help dev dev-dev dev-staging dev-prod down clean restart logs logs-frontend logs-backend logs-db logs-redis logs-filter logs-aggregate health ps shell-frontend shell-backend shell-db shell-redis db-seed db-reset db-backup db-restore db-migrate db-rollback lint lint-fix format test test-backend test-frontend check-docker pre-flight validate-env check-ports troubleshoot prune rebuild rebuild-backend rebuild-frontend update up stop profile-switch profile-status generate-certs trust-cert list-families show-family feedback metrics-view metrics-clear security-audit

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
BLUE   := \033[0;34m
NC     := \033[0m # No Color

# Project name
PROJECT_NAME := wander
COMPOSE_FILE := docker-compose.yml
PROFILE ?= dev

# Default target
.DEFAULT_GOAL := help

##@ Primary Commands

dev: pre-flight ## Start all services (default: dev profile, use JOB_FAMILY=name for job family)
	@if [ ! -z "$(JOB_FAMILY)" ]; then \
		echo "$(YELLOW)Using job family: $(JOB_FAMILY)$(NC)"; \
		COMPONENTS=$$(./scripts/resolve-components.sh $(JOB_FAMILY) $(foreach var,$(filter NO_%,$(.VARIABLES)),$(var)=$($(var)))); \
		echo "$(BLUE)Components: $$COMPONENTS$(NC)"; \
	fi
	@echo "$(GREEN)Starting all services with $(PROFILE) profile...$(NC)"
	@if [ -f ".env.$(PROFILE)" ]; then \
		./scripts/switch-profile.sh $(PROFILE); \
	fi
	@docker-compose -f $(COMPOSE_FILE) -f docker-compose.$(PROFILE).yml up -d || (echo "$(RED)❌ Failed to start services$(NC)" && exit 1)
	@echo "$(GREEN)✓ Services started with $(PROFILE) profile!$(NC)"
	@echo "$(BLUE)Frontend: http://localhost:3000$(NC)"
	@echo "$(BLUE)Backend:  http://localhost:4000$(NC)"
	@echo "$(BLUE)Postgres: localhost:5432$(NC)"
	@echo "$(BLUE)Redis:    localhost:6379$(NC)"

dev-dev: pre-flight ## Start with dev profile
	@$(MAKE) dev PROFILE=dev

dev-staging: pre-flight ## Start with staging profile
	@$(MAKE) dev PROFILE=staging

dev-prod: pre-flight ## Start with prod profile
	@$(MAKE) dev PROFILE=prod

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
	@echo "$(YELLOW)Running all tests...$(NC)"
	@echo "$(BLUE)Backend tests:$(NC)"
	@docker-compose exec -T backend npm test || true
	@echo "$(BLUE)Frontend tests:$(NC)"
	@docker-compose exec -T frontend npm test || true
	@echo "$(GREEN)✓ Tests completed$(NC)"

test-backend: ## Run backend tests only
	@echo "$(YELLOW)Running backend tests...$(NC)"
	@docker-compose exec -T backend npm test

test-frontend: ## Run frontend tests only
	@echo "$(YELLOW)Running frontend tests...$(NC)"
	@docker-compose exec -T frontend npm test

test-e2e: ## Run end-to-end tests
	@echo "$(YELLOW)Running E2E tests...$(NC)"
	@cd e2e && npm test || echo "$(YELLOW)E2E tests require Playwright setup$(NC)"

##@ Code Quality

lint: ## Lint all code (backend and frontend)
	@echo "$(YELLOW)Linting all code...$(NC)"
	@./scripts/lint-all.sh

lint-fix: ## Auto-fix linting issues
	@echo "$(YELLOW)Auto-fixing linting issues...$(NC)"
	@docker-compose exec -T backend npm run lint -- --fix || true
	@docker-compose exec -T frontend npm run lint -- --fix || true
	@echo "$(GREEN)✓ Linting fixes applied$(NC)"

format: ## Format all code with Prettier
	@echo "$(YELLOW)Formatting code with Prettier...$(NC)"
	@npx prettier --write "**/*.{js,jsx,json,md,yml,yaml}" --ignore-path .prettierignore || true
	@echo "$(GREEN)✓ Code formatted$(NC)"

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

##@ Profiles

profile-switch: ## Switch environment profile (usage: make profile-switch PROFILE=staging)
	@if [ -z "$(PROFILE)" ]; then \
		echo "$(RED)Error: PROFILE parameter required$(NC)"; \
		echo "$(YELLOW)Usage: make profile-switch PROFILE=staging$(NC)"; \
		echo "$(YELLOW)Available profiles: dev, staging, prod$(NC)"; \
		exit 1; \
	fi
	@./scripts/switch-profile.sh $(PROFILE)

profile-status: ## Show current environment profile
	@if [ -f ".env.current" ]; then \
		CURRENT=$$(cat .env.current); \
		echo "$(GREEN)Current profile: $$CURRENT$(NC)"; \
	else \
		echo "$(YELLOW)No profile set (using default: dev)$(NC)"; \
	fi

##@ SSL/HTTPS

generate-certs: ## Generate SSL certificates for local HTTPS
	@./scripts/generate-certs.sh

trust-cert: ## Trust SSL certificate (macOS/Linux)
	@./scripts/trust-cert.sh

##@ Job Families

list-families: ## List all available job families
	@echo "$(BLUE)Available Job Families:$(NC)"
	@if command -v yq &> /dev/null; then \
		yq eval '.job_families | keys | .[]' config/job-families.yml | while read family; do \
			desc=$$(yq eval ".job_families.$$family.description" config/job-families.yml); \
			echo "$(GREEN)  $$family$(NC): $$desc"; \
		done; \
	else \
		grep "^  [a-z-]*:" config/job-families.yml | sed 's/:$//' | sed 's/^  /  - /'; \
	fi

show-family: ## Show components for a job family (usage: make show-family JOB_FAMILY=ml-engineer)
	@if [ -z "$(JOB_FAMILY)" ]; then \
		echo "$(RED)Error: JOB_FAMILY parameter required$(NC)"; \
		echo "$(YELLOW)Usage: make show-family JOB_FAMILY=ml-engineer$(NC)"; \
		exit 1; \
	fi
	@./scripts/show-family.sh $(JOB_FAMILY)

##@ Metrics & Feedback

feedback: ## Submit anonymous feedback
	@./scripts/submit-feedback.sh

metrics-view: ## View collected metrics
	@if [ -f ".metrics/metrics.json" ]; then \
		echo "$(BLUE)Setup Metrics:$(NC)"; \
		cat .metrics/metrics.json | python3 -m json.tool 2>/dev/null || cat .metrics/metrics.json; \
		echo ""; \
	fi
	@if [ -f ".metrics/feedback.json" ]; then \
		echo "$(BLUE)Feedback:$(NC)"; \
		cat .metrics/feedback.json | python3 -m json.tool 2>/dev/null || cat .metrics/feedback.json; \
	fi

metrics-clear: ## Clear collected metrics
	@echo "$(YELLOW)Clearing metrics...$(NC)"
	@rm -rf .metrics/*.json
	@echo "$(GREEN)✓ Metrics cleared$(NC)"

security-audit: ## Run security audit
	@./scripts/security-audit.sh

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

