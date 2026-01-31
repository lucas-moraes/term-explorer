#!/usr/bin/env zsh
# ============================================================================
# UNINSTALL.SH - Uninstall term-explorer
# ============================================================================
# This script removes term-explorer from your system
# ============================================================================

set -e

# Color helpers
error() { print -P "%F{red}❌ $1%f" >&2; }
warn()  { print -P "%F{yellow}⚠️  $1%f"; }
info()  { print -P "%F{blue}ℹ️  $1%f"; }
success() { print -P "%F{green}✅ $1%f"; }

# Detect installation type
detect_install_type() {
    local install_type="unknown"

    # Check if installed via package manager
    if command -v brew &>/dev/null && brew list term-explorer &>/dev/null; then
        install_type="brew"
    elif pacman -Qi term-explorer &>/dev/null 2>&1; then
        install_type="aur"
    # Check if installed via Makefile
    elif [[ -f "/usr/local/bin/te" ]] || [[ -f "$HOME/.local/bin/te" ]]; then
        install_type="makefile"
    # Check if installed manually
    elif [[ -f "$HOME/.config/term-explorer/term-explorer.zsh" ]]; then
        install_type="manual"
    fi

    echo "$install_type"
}

# Uninstall from Homebrew
uninstall_brew() {
    info "Uninstalling via Homebrew..."
    brew uninstall term-explorer
    success "Uninstalled via Homebrew"
}

# Uninstall from AUR
uninstall_aur() {
    info "Uninstalling via AUR..."
    sudo pacman -Rns term-explorer
    success "Uninstalled via AUR"
}

# Uninstall manual installation
uninstall_manual() {
    local install_dir="$HOME/.config/term-explorer"
    local bin_link="$HOME/.local/bin/te"

    info "Removing manual installation..."

    # Remove binary symlink
    if [[ -L "$bin_link" ]]; then
        rm "$bin_link"
        success "Removed symlink: $bin_link"
    fi

    # Remove installation directory
    if [[ -d "$install_dir" ]]; then
        # Ask about bookmarks
        if [[ -f "$install_dir/bookmarks" ]]; then
            warn "Bookmarks file found at: $install_dir/bookmarks"
            print -Pn "%F{yellow}Keep bookmarks? [y/N]: %f"
            local keep_bookmarks
            read -r keep_bookmarks
            if [[ "$keep_bookmarks" != "y" && "$keep_bookmarks" != "Y" ]]; then
                rm -rf "$install_dir"
                success "Removed installation directory: $install_dir"
            else
                # Backup bookmarks
                mkdir -p "$HOME/.config/term-explorer-backup"
                cp "$install_dir/bookmarks" "$HOME/.config/term-explorer-backup/"
                rm -rf "$install_dir"
                success "Removed installation directory (bookmarks backed up)"
            fi
        else
            rm -rf "$install_dir"
            success "Removed installation directory: $install_dir"
        fi
    fi
}

# Remove from .zshrc
remove_from_zshrc() {
    local zshrc="$HOME/.zshrc"
    local source_line='source ~/.config/term-explorer/term-explorer.zsh'
    local oh_my_zsh_plugin='plugins=(... term-explorer ...)'

    if [[ -f "$zshrc" ]]; then
        local temp_file=$(mktemp)

        # Filter out term-explorer lines
        grep -v "term-explorer" "$zshrc" > "$temp_file" || true

        # Check if anything was removed
        if ! diff -q "$zshrc" "$temp_file" &>/dev/null; then
            mv "$temp_file" "$zshrc"
            success "Removed term-explorer from .zshrc"
            warn "Please run: source ~/.zshrc"
        else
            rm "$temp_file"
            info "No term-explorer references found in .zshrc"
        fi
    fi
}

# Remove Oh-My-Zsh plugin
remove_oh_my_zsh_plugin() {
    local omz_plugin_dir="$HOME/.oh-my-zsh/custom/plugins/term-explorer"

    if [[ -d "$omz_plugin_dir" ]]; then
        rm -rf "$omz_plugin_dir"
        success "Removed Oh-My-Zsh plugin"

        # Update .zshrc to remove plugin
        local zshrc="$HOME/.zshrc"
        if [[ -f "$zshrc" ]]; then
            sed -i.bak '/term-explorer/d' "$zshrc" 2>/dev/null || true
            success "Updated .zshrc"
        fi
    fi
}

# Main uninstall function
main() {
    print -P "%F{cyan}╭──────────────────────────────────────────────────────────────────╮%f"
    print -P "%F{cyan}│%F{bold}              TERM-EXPLORER UNINSTALLER%f %F{cyan}                          │%f"
    print -P "%F{cyan}╰──────────────────────────────────────────────────────────────────╯%f"
    echo ""

    local install_type=$(detect_install_type)

    case "$install_type" in
        brew)
            uninstall_brew
            ;;
        aur)
            uninstall_aur
            ;;
        makefile)
            uninstall_manual
            ;;
        manual)
            uninstall_manual
            ;;
        *)
            warn "No installation found. Checking for manual files..."
            uninstall_manual
            ;;
    esac

    # Remove from shell configs
    remove_from_zshrc
    remove_oh_my_zsh_plugin

    echo ""
    print -P "%F{green}════════════════════════════════════════════════════════════%f"
    print -P "%F{green}✅ Uninstallation complete!%f"
    print -P "%F{green}════════════════════════════════════════════════════════════%f"
}

# Run main
main "$@"
