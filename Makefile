# ============================================================================
# MAKEFILE - Term-Explorer Build and Installation
# ============================================================================

# Variables
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
CONFIG_DIR ?= $(HOME)/.config/term-explorer
OMZ_PLUGINS ?= $(HOME)/.oh-my-zsh/custom/plugins
SRC_DIR := $(PWD)
SCRIPT := term-explorer.zsh
PLUGIN_SCRIPT := term-explorer.plugin.zsh

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help install uninstall install-omz clean update test lint

# ============================================================================
# Default target
# ============================================================================
.DEFAULT_GOAL := help

help:
	@echo "$(BLUE)Term-Explorer - Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make [target]"
	@echo ""
	@echo "$(GREEN)Targets:$(NC)"
	@echo "  $(BLUE)install$(NC)        Install term-explorer to $(BINDIR)"
	@echo "  $(BLUE)install-user$(NC)    Install to user directory (~/.local)"
	@echo "  $(BLUE)install-omz$(NC)     Install as Oh-My-Zsh plugin"
	@echo "  $(BLUE)uninstall$(NC)      Remove term-explorer"
	@echo "  $(BLUE)clean$(NC)          Remove generated files"
	@echo "  $(BLUE)update$(NC)          Update from git repository"
	@echo "  $(BLUE)test$(NC)           Run syntax check"
	@echo "  $(BLUE)lint$(NC)           Run shellcheck (if available)"
	@echo ""
	@echo "$(GREEN)Installation options:$(NC)"
	@echo "  PREFIX=/path        Set installation prefix"
	@echo "  BINDIR=/path       Set binary directory"
	@echo "  CONFIG_DIR=/path   Set configuration directory"
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make install"
	@echo "  make install-user"
	@echo "  make install PREFIX=/usr"
	@echo "  make install-omz"

# ============================================================================
# Installation targets
# ============================================================================
install:
	@echo "$(GREEN)Installing term-explorer to $(BINDIR)...$(NC)"
	@install -d $(BINDIR)
	@install -d $(CONFIG_DIR)
	@install -m 644 $(SCRIPT) $(CONFIG_DIR)/$(SCRIPT) || true
	@echo '#!/usr/bin/env zsh' > $(BINDIR)/te
	@echo 'CONFIG_DIR="$${XDG_CONFIG_HOME:-$$HOME/.config}/term-explorer"' >> $(BINDIR)/te
	@echo 'source "$$CONFIG_DIR/term-explorer.zsh"' >> $(BINDIR)/te
	@echo 'term-explorer "$$@"' >> $(BINDIR)/te
	@chmod +x $(BINDIR)/te
	@echo "$(GREEN)✓ Installed to $(BINDIR)/te$(NC)"
	@echo "$(YELLOW)Add to PATH: export PATH=\"$(BINDIR):$$PATH\"$(NC)"

install-user:
	@$(MAKE) BINDIR=$(HOME)/.local/bin CONFIG_DIR=$(HOME)/.config/term-explorer install
	@echo "$(GREEN)✓ Add to PATH: export PATH=\"$$HOME/.local/bin:$$PATH\"$(NC)"

install-omz:
	@echo "$(GREEN)Installing as Oh-My-Zsh plugin...$(NC)"
	@install -d $(OMZ_PLUGINS)/term-explorer
	@install -m 644 $(SCRIPT) $(OMZ_PLUGINS)/term-explorer/$(SCRIPT)
	@install -m 644 plugins/oh-my-zsh/$(PLUGIN_SCRIPT) $(OMZ_PLUGINS)/term-explorer/$(PLUGIN_SCRIPT)
	@echo "$(GREEN)✓ Installed to $(OMZ_PLUGINS)/term-explorer/$(NC)"
	@echo "$(YELLOW)Add plugin to .zshrc: plugins=(... term-explorer ...)$(NC)"
	@echo "$(YELLOW)Then run: source ~/.zshrc$(NC)"

# ============================================================================
# Uninstall target
# ============================================================================
uninstall:
	@echo "$(YELLOW)Uninstalling term-explorer...$(NC)"
	@if [ -f $(BINDIR)/te ]; then \
		rm $(BINDIR)/te; \
		echo "$(GREEN)✓ Removed $(BINDIR)/te$(NC)"; \
	fi
	@echo "$(YELLOW)Config directory preserved: $(CONFIG_DIR)$(NC)"
	@echo "$(YELLOW)To remove manually: rm -rf $(CONFIG_DIR)$(NC)"
	@echo "$(YELLOW)Run ./uninstall.sh for complete removal$(NC)"

# ============================================================================
# Update target
# ============================================================================
update:
	@echo "$(GREEN)Updating from git repository...$(NC)"
	@if [ -d .git ]; then \
		git pull; \
		echo "$(GREEN)✓ Updated successfully$(NC)"; \
	else \
		echo "$(RED)✗ Not a git repository$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# Test target
# ============================================================================
test:
	@echo "$(GREEN)Running syntax check...$(NC)"
	@if command -v zsh >/dev/null 2>&1; then \
		if zsh -n $(SCRIPT); then \
			echo "$(GREEN)✓ Syntax check passed$(NC)"; \
		else \
			echo "$(RED)✗ Syntax check failed$(NC)"; \
			exit 1; \
		fi \
	else \
		echo "$(RED)✗ zsh not found$(NC)"; \
		exit 1; \
	fi

# ============================================================================
# Lint target
# ============================================================================
lint:
	@echo "$(GREEN)Running ShellCheck...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		if shellcheck $(SCRIPT); then \
			echo "$(GREEN)✓ No issues found$(NC)"; \
		else \
			echo "$(RED)✗ Issues found$(NC)"; \
			exit 1; \
		fi \
	else \
		echo "$(YELLOW)✗ ShellCheck not installed$(NC)"; \
		echo "$(YELLOW)Install: https://github.com/koalaman/shellcheck$(NC)"; \
	fi

# ============================================================================
# Clean target
# ============================================================================
clean:
	@echo "$(GREEN)Cleaning up...$(NC)"
	@rm -f .DS_Store
	@rm -rf .zwc *.zwc
	@echo "$(GREEN)✓ Cleaned$(NC)"

# ============================================================================
# Help target
# ============================================================================
version:
	@echo "$(BLUE)term-explorer$(NC) v$$(grep 'TERM_EXPLORER_VERSION' $(SCRIPT) | head -1 | cut -d'"' -f2)
