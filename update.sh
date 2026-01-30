#!/usr/bin/env zsh
# ============================================================================
# UPDATE.SH - Self-update term-explorer from git repository
# ============================================================================
# Usage: ./update.sh [options]
# Options:
#   --force    Force update even if already up to date
#   --dev      Update to latest development version
# ============================================================================

set -e

# Color helpers
error() { print -P "%F{red}❌ $1%f" >&2; }
warn()  { print -P "%F{yellow}⚠️  $1%f"; }
info()  { print -P "%F{blue}ℹ️  $1%f"; }
success() { print -P "%F{green}✅ $1%f"; }

# Parse arguments
FORCE_UPDATE=false
DEV_UPDATE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --dev)
            DEV_UPDATE=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            print -P "Usage: $0 [--force] [--dev]"
            exit 1
            ;;
    esac
done

# Get current version
get_current_version() {
    grep 'TERM_EXPLORER_VERSION=' term-explorer.zsh | head -1 | cut -d'"' -f2
}

# Get current branch
get_current_branch() {
    git branch --show-current 2>/dev/null || echo "unknown"
}

# Check if git repository
check_git_repo() {
    if [[ ! -d .git ]]; then
        error "Not a git repository"
        warn "Clone from: https://github.com/YOUR_USERNAME/term-explorer.git"
        exit 1
    fi
}

# Update repository
update_repo() {
    local branch="main"
    if [[ "$DEV_UPDATE" == "true" ]]; then
        branch="dev"
    fi

    info "Fetching updates..."
    git fetch origin

    local current_branch=$(get_current_branch)
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/$branch 2>/dev/null || echo "")

    if [[ "$local_commit" == "$remote_commit" && "$FORCE_UPDATE" == "false" ]]; then
        success "Already up to date"
        return 0
    fi

    info "Updating to $branch branch..."
    if git checkout "$branch" 2>/dev/null || git checkout -b "$branch" origin/$branch 2>/dev/null; then
        git pull origin "$branch"
        success "Updated successfully"
    else
        error "Failed to update to $branch branch"
        exit 1
    fi
}

# Show changes
show_changes() {
    print -P "\n%F{cyan}─────────────────────────────────────────%f"
    print -P "%F{cyan}What's New:%f"
    print -P "%F{cyan}─────────────────────────────────────────%f"

    if [[ -f CHANGELOG.md ]]; then
        # Show latest changelog entry
        awk '/^## \[/ {p=1} p && /^## \[/{if(!first)exit;first=1}' CHANGELOG.md | head -50
    fi

    print -P "%F{cyan}─────────────────────────────────────────%f\n"
}

# Reload shell
reload_shell() {
    print -P "%F{yellow}⚠️  Reload your shell to use the updated version:%f"
    print -P "%F{yellow}   exec zsh%f"
}

# Main function
main() {
    print -P "%F{cyan}╭──────────────────────────────────────────────────────────────╮%f"
    print -P "%F{cyan}│%F{bold}            TERM-EXPLORER UPDATER              %F{cyan}│%f"
    print -P "%F{cyan}╰──────────────────────────────────────────────────────────────╯%f"
    echo ""

    local old_version=$(get_current_version)
    info "Current version: v$old_version"

    # Check git repo
    check_git_repo

    # Update repository
    update_repo

    local new_version=$(get_current_version)

    if [[ "$old_version" != "$new_version" ]]; then
        print -P "%F{green}──────────────────────────────────────────────────────────────%f"
        print -P "%F{green}Version: $old_version → $new_version%f"
        print -P "%F{green}──────────────────────────────────────────────────────────────%f"

        # Show changelog
        show_changes

        # Check syntax
        info "Checking syntax..."
        if zsh -n term-explorer.zsh; then
            success "Syntax check passed"
        else
            error "Syntax check failed!"
            warn "Please report this issue"
            exit 1
        fi

        reload_shell
    fi
}

# Run main
main "$@"
