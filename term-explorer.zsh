#!/usr/bin/env zsh
# ============================================================================
# TERM-EXPLORER - Interactive File Explorer for Zsh
# ============================================================================
# Version: 1.0.0
# Repository: https://github.com/YOUR_USERNAME/term-explorer
# License: MIT
#
# Dependencies:
#   Required: fzf
#   Optional: bat/batcat (syntax highlighting), eza (modern ls)
#
# Usage:
#   term-explorer [directory]
#   te [directory]
# ============================================================================

# ----------------------------------------------------------------------------
# Global Configuration
# ----------------------------------------------------------------------------
typeset -g TERM_EXPLORER_VERSION="1.0.0"
typeset -g TERM_EXPLORER_SHOW_HIDDEN=${TERM_EXPLORER_SHOW_HIDDEN:-1}

# Tokyo Night theme for fzf
typeset -g TERM_EXPLORER_FZF_COLORS="--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7"
TERM_EXPLORER_FZF_COLORS+=",fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff"
TERM_EXPLORER_FZF_COLORS+=",info:#7aa2f7,prompt:#7dcfff,pointer:#ff007c"
TERM_EXPLORER_FZF_COLORS+=",marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
TERM_EXPLORER_FZF_COLORS+=",border:#565f89"

# ----------------------------------------------------------------------------
# _te_check_deps: Check if required dependencies are installed
# Returns: 0 if all required deps are present, 1 otherwise
# ----------------------------------------------------------------------------
_te_check_deps() {
    local missing=()
    local warnings=()
    
    # Required dependency
    if ! command -v fzf &>/dev/null; then
        missing+=("fzf")
    fi
    
    # Check for missing required dependencies
    if (( ${#missing[@]} > 0 )); then
        print -P "%F{red}╭─────────────────────────────────────────────────────────╮%f"
        print -P "%F{red}│%f  %F{yellow}term-explorer:%f Missing required dependencies          %F{red}│%f"
        print -P "%F{red}├─────────────────────────────────────────────────────────┤%f"
        print -P "%F{red}│%f  Missing: %F{cyan}${missing[*]}%f"
        print -P "%F{red}│%f                                                         "
        print -P "%F{red}│%f  %F{green}macOS:%f  brew install ${missing[*]}"
        print -P "%F{red}│%f  %F{green}Ubuntu:%f sudo apt install ${missing[*]}"
        print -P "%F{red}│%f  %F{green}Arch:%f   sudo pacman -S ${missing[*]}"
        print -P "%F{red}╰─────────────────────────────────────────────────────────╯%f"
        return 1
    fi
    
    # Optional dependencies warnings (non-blocking)
    if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
        warnings+=("bat (using 'cat' for preview)")
    fi
    
    if ! command -v eza &>/dev/null; then
        warnings+=("eza (using 'ls' for listing)")
    fi
    
    # Show warnings for optional dependencies
    if (( ${#warnings[@]} > 0 )); then
        for warn in "${warnings[@]}"; do
            print -P "%F{yellow}[term-explorer]%f Warning: '$warn' not found"
        done
    fi
    
    return 0
}

# ----------------------------------------------------------------------------
# _te_get_bat: Returns the available bat command (bat or batcat)
# Returns: Command name or empty string
# ----------------------------------------------------------------------------
_te_get_bat() {
    if command -v bat &>/dev/null; then
        echo "bat"
    elif command -v batcat &>/dev/null; then
        echo "batcat"
    else
        echo ""
    fi
}

# ----------------------------------------------------------------------------
# _te_get_file_size: Get human-readable file size (cross-platform)
# Arguments: $1 = file path
# ----------------------------------------------------------------------------
_te_get_file_size() {
    local file="$1"
    local size
    
    # Try GNU stat first, then BSD stat
    if stat --version &>/dev/null 2>&1; then
        # GNU stat (Linux)
        size=$(stat -c%s "$file" 2>/dev/null)
    else
        # BSD stat (macOS)
        size=$(stat -f%z "$file" 2>/dev/null)
    fi
    
    # Convert to human-readable
    if command -v numfmt &>/dev/null; then
        echo $(numfmt --to=iec $size 2>/dev/null)
    elif command -v gnumfmt &>/dev/null; then
        echo $(gnumfmt --to=iec $size 2>/dev/null)
    else
        # Fallback: manual conversion
        if (( size >= 1073741824 )); then
            printf "%.1fG" $((size / 1073741824.0))
        elif (( size >= 1048576 )); then
            printf "%.1fM" $((size / 1048576.0))
        elif (( size >= 1024 )); then
            printf "%.1fK" $((size / 1024.0))
        else
            echo "${size}B"
        fi
    fi
}

# ----------------------------------------------------------------------------
# _te_preview: Generate preview for file or directory
# Arguments: $1 = target path
# ----------------------------------------------------------------------------
_te_preview() {
    local target="$1"
    
    # Remove icon prefix if present (handles "📁 dirname" format)
    if [[ "$target" == *" "* ]]; then
        target="${target#* }"
    fi
    
    # Handle empty selection
    if [[ -z "$target" ]]; then
        echo "No item selected"
        return
    fi
    
    # Directory preview
    if [[ -d "$target" ]]; then
        print -P "%F{blue}%B📁 Directory:%b%f $target"
        echo "────────────────────────────────────────"
        
        if command -v eza &>/dev/null; then
            eza --color=always --icons=always -la --group-directories-first "$target" 2>/dev/null
        else
            ls -la --color=always "$target" 2>/dev/null || ls -laG "$target" 2>/dev/null || ls -la "$target"
        fi
        return
    fi
    
    # File preview
    if [[ -f "$target" ]]; then
        local bat_cmd=$(_te_get_bat)
        local file_size=$(_te_get_file_size "$target")
        local file_type=$(file -b "$target" 2>/dev/null | head -c 50)
        
        print -P "%F{green}%B📄 File:%b%f $target"
        print -P "%F{cyan}📊 Size:%f $file_size"
        print -P "%F{magenta}📋 Type:%f $file_type"
        echo "────────────────────────────────────────"
        
        # Check if binary file
        if file "$target" 2>/dev/null | grep -qE "binary|executable|data|archive|image|audio|video"; then
            print -P "%F{yellow}[Binary file - preview not available]%f"
            file "$target" 2>/dev/null
            return
        fi
        
        # Text file preview
        if [[ -n "$bat_cmd" ]]; then
            $bat_cmd --color=always --style=numbers,header --line-range=:300 "$target" 2>/dev/null
        else
            head -n 100 "$target" 2>/dev/null
        fi
        return
    fi
    
    # Symbolic link
    if [[ -L "$target" ]]; then
        local link_target=$(readlink "$target" 2>/dev/null)
        print -P "%F{cyan}%B🔗 Symbolic link:%b%f $target"
        print -P "%F{cyan}   → Points to:%f $link_target"
        echo "────────────────────────────────────────"
        
        if [[ -e "$link_target" ]]; then
            _te_preview "$link_target"
        else
            print -P "%F{red}[Broken link - target does not exist]%f"
        fi
        return
    fi
    
    # Unknown type
    print -P "%F{red}❓ Item not found:%f $target"
}

# ----------------------------------------------------------------------------
# _te_get_icon: Returns icon for file based on extension/type
# Arguments: $1 = filename
# ----------------------------------------------------------------------------
_te_get_icon() {
    local file="$1"
    local ext="${file:e:l}"  # lowercase extension
    
    # Special files
    case "$file" in
        .gitignore|.gitattributes|.gitmodules)  echo ""; return ;;
        .env|.env.*)                             echo "🔐"; return ;;
        Dockerfile|docker-compose*)              echo "🐳"; return ;;
        Makefile|makefile)                       echo "🔧"; return ;;
        LICENSE|license*)                        echo "📜"; return ;;
        README*|readme*)                         echo "📖"; return ;;
        package.json)                            echo "📦"; return ;;
        *.lock)                                  echo "🔒"; return ;;
    esac
    
    # By extension
    case "$ext" in
        # Shell scripts
        sh|bash|zsh|fish|ksh)           echo "🐚" ;;
        
        # Programming languages
        py|pyw|pyx)                     echo "🐍" ;;
        js|mjs|cjs)                     echo "📜" ;;
        ts|tsx)                         echo "💠" ;;
        jsx)                            echo "⚛️ " ;;
        rb)                             echo "💎" ;;
        go)                             echo "🔷" ;;
        rs)                             echo "🦀" ;;
        c|h)                            echo "🔵" ;;
        cpp|hpp|cc|cxx)                 echo "🔷" ;;
        java|jar)                       echo "☕" ;;
        php)                            echo "🐘" ;;
        swift)                          echo "🍎" ;;
        kt|kts)                         echo "🟣" ;;
        lua)                            echo "🌙" ;;
        r)                              echo "📊" ;;
        sql)                            echo "🗄️ " ;;
        
        # Config/Data
        json|jsonc)                     echo "📋" ;;
        yml|yaml)                       echo "⚙️ " ;;
        toml)                           echo "⚙️ " ;;
        xml)                            echo "📰" ;;
        ini|cfg|conf)                   echo "🔧" ;;
        env)                            echo "🔐" ;;
        
        # Documents
        md|markdown)                    echo "📝" ;;
        txt)                            echo "📄" ;;
        rst)                            echo "📝" ;;
        pdf)                            echo "📕" ;;
        doc|docx)                       echo "📘" ;;
        xls|xlsx)                       echo "📗" ;;
        ppt|pptx)                       echo "📙" ;;
        csv)                            echo "📊" ;;
        
        # Web
        html|htm)                       echo "🌐" ;;
        css|scss|sass|less)             echo "🎨" ;;
        svg)                            echo "🖼️ " ;;
        
        # Images
        jpg|jpeg|png|gif|webp|bmp|ico)  echo "🖼️ " ;;
        
        # Audio/Video
        mp3|wav|flac|ogg|m4a|aac)       echo "🎵" ;;
        mp4|mkv|avi|mov|webm|wmv)       echo "🎬" ;;
        
        # Archives
        zip|tar|gz|bz2|xz|rar|7z)       echo "📦" ;;
        
        # Misc
        log)                            echo "📋" ;;
        bak|backup|old)                 echo "💾" ;;
        tmp|temp)                       echo "⏳" ;;
        
        # Default
        *)
            # Check if executable
            if [[ -x "$file" ]]; then
                echo "⚡"
            else
                echo "📄"
            fi
            ;;
    esac
}

# ----------------------------------------------------------------------------
# _te_list: List files and directories with icons and colors
# Arguments: $1 = show_hidden (1 or 0)
# ----------------------------------------------------------------------------
_te_list() {
    local show_hidden="${1:-1}"
    
    # Add parent directory option (except at root)
    if [[ "$PWD" != "/" ]]; then
        echo "📁 .."
    fi
    
    # List directories first
    local dirs=()
    local files=()
    local links=()
    
    # Collect items
    if [[ "$show_hidden" == "1" ]]; then
        # Include hidden files
        for item in *(N/); do
            dirs+=("$item")
        done
        for item in .*(N/); do
            [[ "$item" != "." && "$item" != ".." ]] && dirs+=("$item")
        done
        for item in *(N.); do
            files+=("$item")
        done
        for item in .*(N.); do
            files+=("$item")
        done
        for item in *(N@); do
            links+=("$item")
        done
        for item in .*(N@); do
            links+=("$item")
        done
    else
        # Exclude hidden files
        for item in *(N/); do
            dirs+=("$item")
        done
        for item in *(N.); do
            files+=("$item")
        done
        for item in *(N@); do
            links+=("$item")
        done
    fi
    
    # Sort and output directories
    for dir in ${(o)dirs}; do
        echo "📁 $dir"
    done
    
    # Sort and output files with appropriate icons
    for file in ${(o)files}; do
        local icon=$(_te_get_icon "$file")
        echo "$icon $file"
    done
    
    # Sort and output symbolic links
    for link in ${(o)links}; do
        echo "🔗 $link"
    done
}

# ----------------------------------------------------------------------------
# _te_copy: Copy text to clipboard (cross-platform)
# Arguments: $1 = text to copy
# Returns: 0 on success, 1 on failure
# ----------------------------------------------------------------------------
_te_copy() {
    local text="$1"
    
    # macOS
    if command -v pbcopy &>/dev/null; then
        echo -n "$text" | pbcopy
        return 0
    fi
    
    # Linux: X11 with xclip
    if command -v xclip &>/dev/null; then
        echo -n "$text" | xclip -selection clipboard
        return 0
    fi
    
    # Linux: X11 with xsel
    if command -v xsel &>/dev/null; then
        echo -n "$text" | xsel --clipboard --input
        return 0
    fi
    
    # Linux: Wayland
    if command -v wl-copy &>/dev/null; then
        echo -n "$text" | wl-copy
        return 0
    fi
    
    # Windows WSL
    if command -v clip.exe &>/dev/null; then
        echo -n "$text" | clip.exe
        return 0
    fi
    
    # Termux (Android)
    if command -v termux-clipboard-set &>/dev/null; then
        echo -n "$text" | termux-clipboard-set
        return 0
    fi
    
    print -P "%F{red}No clipboard tool found%f"
    print -P "%F{yellow}Install: pbcopy (macOS), xclip, xsel (Linux), or wl-copy (Wayland)%f"
    return 1
}

# ----------------------------------------------------------------------------
# _te_actions: Action menu for selected file
# Arguments: $1 = filename
# Returns: 0 to continue exploring, 1 to exit
# ----------------------------------------------------------------------------
_te_actions() {
    local file="$1"
    local abs_path="$PWD/$file"
    
    # Build action menu
    local actions=(
        "📝 Edit in \$EDITOR"
        "📋 Copy absolute path"
        "📋 Copy relative path"
        "👁  View full content"
        "🗑️  Delete file"
        "❌ Cancel"
    )
    
    local action=$(printf '%s\n' "${actions[@]}" | \
        fzf --height=50% \
            --border=rounded \
            --prompt="Action: " \
            --header="📄 $file" \
            $TERM_EXPLORER_FZF_COLORS \
            --no-preview \
            --no-sort)
    
    case "$action" in
        *"Edit"*)
            local editor="${EDITOR:-${VISUAL:-vim}}"
            print -P "%F{green}Opening in editor:%f $editor"
            $editor "$file"
            return 0
            ;;
            
        *"absolute"*)
            if _te_copy "$abs_path"; then
                print -P "%F{green}✅ Absolute path copied:%f"
                print -P "   %F{cyan}$abs_path%f"
            fi
            sleep 1
            return 0
            ;;
            
        *"relative"*)
            if _te_copy "$file"; then
                print -P "%F{green}✅ Relative path copied:%f"
                print -P "   %F{cyan}$file%f"
            fi
            sleep 1
            return 0
            ;;
            
        *"View"*)
            local bat_cmd=$(_te_get_bat)
            if [[ -n "$bat_cmd" ]]; then
                $bat_cmd --color=always --style=numbers,header --paging=always "$file"
            else
                less "$file"
            fi
            return 0
            ;;
            
        *"Delete"*)
            echo ""
            print -P "%F{red}%B⚠️  WARNING: You are about to delete:%b%f"
            print -P "   %F{yellow}$abs_path%f"
            echo ""
            print -P "%F{red}This action is irreversible!%f"
            echo ""
            print -Pn "%F{yellow}Type 'yes' to confirm: %f"
            
            local confirmation
            read -r confirmation
            
            if [[ "$confirmation" == "yes" ]]; then
                if rm "$file" 2>/dev/null; then
                    print -P "%F{green}✅ File deleted successfully%f"
                else
                    print -P "%F{red}❌ Error deleting file%f"
                fi
            else
                print -P "%F{blue}❌ Deletion cancelled%f"
            fi
            sleep 1
            return 0
            ;;
            
        *"Cancel"*|"")
            return 0
            ;;
    esac
    
    return 0
}

# ----------------------------------------------------------------------------
# term-explorer: Main function
# Arguments: $1 = initial directory (optional, defaults to current)
# ----------------------------------------------------------------------------
term-explorer() {
    # Check dependencies
    _te_check_deps || return 1
    
    # Parse arguments
    local start_dir="${1:-.}"
    
    # Validate directory
    if [[ ! -d "$start_dir" ]]; then
        print -P "%F{red}❌ Directory not found:%f $start_dir"
        return 1
    fi
    
    # Change to initial directory
    cd "$start_dir" || return 1
    
    local selection
    local item
    local initial_dir="$PWD"
    
    # Store current directory for restoration on exit
    local original_dir="$OLDPWD"
    
    # Main navigation loop
    while true; do
        # Build header with keyboard shortcuts
        local header="╭────────────────────────────────────────────────────────────────╮
│  %F{green}Enter%f: Select │ %F{yellow}Esc%f: Exit │ %F{cyan}^R%f: Refresh │ %F{magenta}^H%f: Parent │
╰────────────────────────────────────────────────────────────────╯
%F{blue}📂 $PWD%f"

        # Run fzf with preview
        selection=$(_te_list "$TERM_EXPLORER_SHOW_HIDDEN" | \
            fzf --height=80% \
                --border=rounded \
                --prompt="❯ " \
                --header="$header" \
                --header-lines=0 \
                --preview="_te_preview {}" \
                --preview-window=right:50%:wrap:border-left \
                --bind="ctrl-r:reload(_te_list $TERM_EXPLORER_SHOW_HIDDEN)" \
                --bind="ctrl-h:become(echo '📁 ..')" \
                --expect=ctrl-h \
                $TERM_EXPLORER_FZF_COLORS \
                --ansi)
        
        local fzf_exit=$?
        
        # Parse fzf output (first line is expected key, second is selection)
        local expected_key=$(echo "$selection" | head -1)
        selection=$(echo "$selection" | tail -1)
        
        # Handle Ctrl-H
        if [[ "$expected_key" == "ctrl-h" || "$selection" == "📁 .." ]]; then
            if [[ "$PWD" != "/" ]]; then
                cd ..
                continue
            fi
        fi
        
        # User pressed Esc or Ctrl-C
        if [[ -z "$selection" && -z "$expected_key" ]]; then
            break
        fi
        
        # Skip if nothing selected
        [[ -z "$selection" ]] && continue
        
        # Extract item name (remove icon prefix)
        item="${selection#* }"
        
        # Handle selection
        if [[ "$item" == ".." ]]; then
            # Go up one level
            [[ "$PWD" != "/" ]] && cd ..
            
        elif [[ -d "$item" ]]; then
            # Enter directory
            cd "$item"
            
        elif [[ -f "$item" ]]; then
            # Show action menu for file
            _te_actions "$item"
            
        elif [[ -L "$item" ]]; then
            # Handle symbolic link
            local link_target=$(readlink -f "$item" 2>/dev/null || readlink "$item")
            if [[ -d "$link_target" ]]; then
                cd "$item"
            elif [[ -f "$link_target" ]]; then
                _te_actions "$item"
            else
                print -P "%F{red}❌ Broken link:%f $item"
                sleep 1
            fi
        else
            print -P "%F{red}❌ Unrecognized item:%f $item"
            sleep 1
        fi
    done
    
    # Show final directory
    echo ""
    print -P "%F{blue}📂 Current directory:%f $PWD"
}

# ----------------------------------------------------------------------------
# Convenience alias
# ----------------------------------------------------------------------------
alias te='term-explorer'

# ----------------------------------------------------------------------------
# Version command
# ----------------------------------------------------------------------------
term-explorer-version() {
    print -P "%F{cyan}term-explorer%f v$TERM_EXPLORER_VERSION"
}

# ----------------------------------------------------------------------------
# Help command
# ----------------------------------------------------------------------------
term-explorer-help() {
    cat << 'EOF'
╭──────────────────────────────────────────────────────────────────╮
│                      TERM-EXPLORER                               │
│              Interactive File Explorer for Zsh                   │
╰──────────────────────────────────────────────────────────────────╯

USAGE:
    term-explorer [directory]
    te [directory]

KEYBOARD SHORTCUTS:
    Enter       Select item (enter directory / open action menu)
    Esc         Exit explorer
    Ctrl-R      Refresh file list
    Ctrl-H      Go to parent directory
    ↑/↓         Navigate list
    Type        Fuzzy search filter

FILE ACTIONS:
    📝 Edit         Open file in $EDITOR
    📋 Copy path    Copy absolute or relative path to clipboard
    👁  View         View file content with pager
    🗑️  Delete       Delete file (with confirmation)

CONFIGURATION:
    TERM_EXPLORER_SHOW_HIDDEN=1    Show hidden files (default: 1)
    EDITOR=vim                     Editor for file editing

DEPENDENCIES:
    Required: fzf
    Optional: bat (syntax highlighting), eza (modern ls)

EXAMPLES:
    te              Open explorer in current directory
    te ~/projects   Open explorer in ~/projects
    te /var/log     Open explorer in /var/log

EOF
}
