#!/usr/bin/env bash
# ============================================================================
# Term-Explorer Installation Script
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Installation paths
INSTALL_DIR="${TERM_EXPLORER_INSTALL_DIR:-$HOME/.config/term-explorer}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------------

print_header() {
    echo -e "${CYAN}"
    echo "╭──────────────────────────────────────────────────────────────────╮"
    echo "│                      TERM-EXPLORER                               │"
    echo "│              Interactive File Explorer for Zsh                   │"
    echo "╰──────────────────────────────────────────────────────────────────╯"
    echo -e "${NC}"
}

print_step() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# ----------------------------------------------------------------------------
# Dependency checks
# ----------------------------------------------------------------------------

check_shell() {
    if [[ ! -f "$HOME/.zshrc" ]]; then
        print_warning "~/.zshrc not found. Creating it..."
        touch "$HOME/.zshrc"
    fi
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_required=()
    local missing_optional=()
    
    # Required
    if ! command -v fzf &>/dev/null; then
        missing_required+=("fzf")
    else
        print_success "fzf found"
    fi
    
    # Optional
    if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
        missing_optional+=("bat")
    else
        print_success "bat found"
    fi
    
    if ! command -v eza &>/dev/null; then
        missing_optional+=("eza")
    else
        print_success "eza found"
    fi
    
    # Report missing required dependencies
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        echo ""
        print_error "Missing required dependencies: ${missing_required[*]}"
        echo ""
        echo "Please install them first:"
        echo ""
        echo -e "  ${CYAN}macOS:${NC}  brew install ${missing_required[*]}"
        echo -e "  ${CYAN}Ubuntu:${NC} sudo apt install ${missing_required[*]}"
        echo -e "  ${CYAN}Arch:${NC}   sudo pacman -S ${missing_required[*]}"
        echo ""
        
        read -p "Would you like to continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Report missing optional dependencies
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        echo ""
        print_warning "Missing optional dependencies: ${missing_optional[*]}"
        echo "  These enhance the experience but are not required."
        echo ""
        echo "  Install with:"
        echo -e "    ${CYAN}macOS:${NC}  brew install ${missing_optional[*]}"
        echo -e "    ${CYAN}Ubuntu:${NC} sudo apt install ${missing_optional[*]}"
        echo -e "    ${CYAN}Arch:${NC}   sudo pacman -S ${missing_optional[*]}"
        echo ""
    fi
}

# ----------------------------------------------------------------------------
# Installation
# ----------------------------------------------------------------------------

install_files() {
    print_step "Installing term-explorer..."
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy main script
    if [[ -f "$SCRIPT_DIR/term-explorer.zsh" ]]; then
        cp "$SCRIPT_DIR/term-explorer.zsh" "$INSTALL_DIR/"
        print_success "Copied term-explorer.zsh to $INSTALL_DIR/"
    else
        print_error "term-explorer.zsh not found in $SCRIPT_DIR"
        exit 1
    fi
    
    # Copy README if exists
    if [[ -f "$SCRIPT_DIR/README.md" ]]; then
        cp "$SCRIPT_DIR/README.md" "$INSTALL_DIR/"
    fi
    
    # Copy LICENSE if exists
    if [[ -f "$SCRIPT_DIR/LICENSE" ]]; then
        cp "$SCRIPT_DIR/LICENSE" "$INSTALL_DIR/"
    fi
}

configure_shell() {
    print_step "Configuring shell..."
    
    local source_line="source \"$INSTALL_DIR/term-explorer.zsh\""
    local zshrc="$HOME/.zshrc"
    
    # Check if already configured
    if grep -q "term-explorer.zsh" "$zshrc" 2>/dev/null; then
        print_warning "term-explorer is already configured in .zshrc"
        
        read -p "Would you like to update the configuration? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Remove old configuration
            sed -i.bak '/term-explorer/d' "$zshrc"
            print_success "Removed old configuration"
        else
            return
        fi
    fi
    
    # Add source line to .zshrc
    echo "" >> "$zshrc"
    echo "# Term-Explorer: Interactive file explorer" >> "$zshrc"
    echo "$source_line" >> "$zshrc"
    
    print_success "Added term-explorer to .zshrc"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

main() {
    print_header
    
    echo "This script will install term-explorer to:"
    echo -e "  ${CYAN}$INSTALL_DIR${NC}"
    echo ""
    
    read -p "Continue with installation? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    echo ""
    
    check_shell
    check_dependencies
    install_files
    configure_shell
    
    echo ""
    echo -e "${GREEN}╭──────────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${GREEN}│${NC}              ${BOLD}Installation complete!${NC}                              ${GREEN}│${NC}"
    echo -e "${GREEN}╰──────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo "To start using term-explorer, either:"
    echo ""
    echo -e "  1. Restart your terminal, or"
    echo -e "  2. Run: ${CYAN}source ~/.zshrc${NC}"
    echo ""
    echo "Then try:"
    echo ""
    echo -e "  ${CYAN}term-explorer${NC}    # or just ${CYAN}te${NC}"
    echo -e "  ${CYAN}term-explorer-help${NC}"
    echo ""
}

# Run main function
main "$@"
