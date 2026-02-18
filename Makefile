.PHONY: help dev dev-notifier dev-task-manager install

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Local development URLs (override production URLs in .env files)
VIS_DOMAIN := http://localhost:3000

help: ## Show this help message
	@echo "$(BLUE)MCP Development Commands$(NC)"
	@echo "Local VIS domain: $(VIS_DOMAIN)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Development commands
dev: ## Start all services in development mode (requires tmux or multiple terminals)
	@echo "$(YELLOW)Starting all services...$(NC)"
	@$(MAKE) -j2 dev-mcp-server-chart dev-mcp-server-chart-backend dev-twitter-mcp

dev-mcp-server-chart-backend: ## Start ANTVIS charting mcp server backend (port 3000)
	@echo "$(BLUE)Starting ANTVIS charting mcp server backend on http://localhost:3000$(NC)"
	@VIS_DOMAIN=$(VIS_DOMAIN) node server.js

dev-mcp-server-chart: ## Start ANTVIS charting mcp server (port 1122)
	@echo "$(BLUE)Starting ANTVIS charting mcp server on http://localhost:1122$(NC)"
	@VIS_REQUEST_SERVER=$(VIS_DOMAIN)/api/gpt-vis node build/index.js --transport streamable


install: ## Install all (uv)
	@echo "$(BLUE)Installing dependencies...$(NC)"
	@$(MAKE) -j2 install-mcp-server-chart-backend install-mcp-server-chart

install-mcp-server-chart-backend: ## Install ANTVIS charting mcp server backend dependencies (npm)
	@echo "$(BLUE)Installing ANTVIS charting mcp server backend dependencies...$(NC)"
	@npm install && npm rebuild canvas && npm run build

install-mcp-server-chart: ## Install ANTVIS charting mcp server dependencies (npm)
	@echo "$(BLUE)Installing ANTVIS charting mcp server dependencies...$(NC)"
	@npm install && npm run build


clean: ## Clean all build artifacts and dependencies
	@echo "$(BLUE)Cleaning all build artifacts and dependencies...$(NC)"
	@$(MAKE) -j2 clean-mcp-server-chart-backend clean-mcp-server-chart

clean-mcp-server-chart-backend: ## Clean ANTVIS charting mcp server backend build artifacts and dependencies
	@echo "$(BLUE)Cleaning ANTVIS charting mcp server backend...$(NC)"
	@rm -rf node_modules build
clean-mcp-server-chart: ## Clean ANTVIS charting mcp server build artifacts and dependencies
	@echo "$(BLUE)Cleaning ANTVIS charting mcp server...$(NC)"
	@rm -rf node_modules build

# Default target
.DEFAULT_GOAL := help