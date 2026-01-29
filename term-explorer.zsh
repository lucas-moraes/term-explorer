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
typeset -g TERM_EXPLORER_VERSION="1.2.0"
typeset -g TERM_EXPLORER_SHOW_HIDDEN=${TERM_EXPLORER_SHOW_HIDDEN:-1}
typeset -g TERM_EXPLORER_PREVIEW=${TERM_EXPLORER_PREVIEW:-0}
typeset -g TERM_EXPLORER_THEME=${TERM_EXPLORER_THEME:-"tokyo-night"}

# Navigation history stack
typeset -ga _TE_HISTORY=()
typeset -g _TE_HISTORY_MAX=50

# ----------------------------------------------------------------------------
# _te_get_theme_colors: Returns fzf color scheme for specified theme
# Arguments: $1 = theme name (optional, uses TERM_EXPLORER_THEME if not set)
# Available themes: tokyo-night, dracula, nord, gruvbox, catppuccin, monokai
# ----------------------------------------------------------------------------
_te_get_theme_colors() {
    local theme="${1:-$TERM_EXPLORER_THEME}"
    local colors=""
    
    case "$theme" in
        tokyo-night|tokyo)
            colors="--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7"
            colors+=",fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff"
            colors+=",info:#7aa2f7,prompt:#7dcfff,pointer:#ff007c"
            colors+=",marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
            colors+=",border:#565f89"
            ;;
        dracula)
            colors="--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
            colors+=",fg+:#f8f8f2,bg+:#44475a,hl+:#ff79c6"
            colors+=",info:#8be9fd,prompt:#50fa7b,pointer:#ff79c6"
            colors+=",marker:#50fa7b,spinner:#50fa7b,header:#6272a4"
            colors+=",border:#6272a4"
            ;;
        nord)
            colors="--color=fg:#d8dee9,bg:#2e3440,hl:#88c0d0"
            colors+=",fg+:#eceff4,bg+:#3b4252,hl+:#8fbcbb"
            colors+=",info:#81a1c1,prompt:#88c0d0,pointer:#bf616a"
            colors+=",marker:#a3be8c,spinner:#b48ead,header:#81a1c1"
            colors+=",border:#4c566a"
            ;;
        gruvbox)
            colors="--color=fg:#ebdbb2,bg:#282828,hl:#fabd2f"
            colors+=",fg+:#ebdbb2,bg+:#3c3836,hl+:#fe8019"
            colors+=",info:#83a598,prompt:#b8bb26,pointer:#fb4934"
            colors+=",marker:#b8bb26,spinner:#fabd2f,header:#83a598"
            colors+=",border:#504945"
            ;;
        catppuccin|catppuccin-mocha)
            colors="--color=fg:#cdd6f4,bg:#1e1e2e,hl:#f5c2e7"
            colors+=",fg+:#cdd6f4,bg+:#313244,hl+:#f5c2e7"
            colors+=",info:#89b4fa,prompt:#94e2d5,pointer:#f38ba8"
            colors+=",marker:#a6e3a1,spinner:#f9e2af,header:#89b4fa"
            colors+=",border:#6c7086"
            ;;
        monokai)
            colors="--color=fg:#f8f8f2,bg:#272822,hl:#f92672"
            colors+=",fg+:#f8f8f2,bg+:#3e3d32,hl+:#ae81ff"
            colors+=",info:#66d9ef,prompt:#a6e22e,pointer:#f92672"
            colors+=",marker:#a6e22e,spinner:#fd971f,header:#75715e"
            colors+=",border:#75715e"
            ;;
        *)
            # Default to tokyo-night if theme not found
            colors="--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7"
            colors+=",fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff"
            colors+=",info:#7aa2f7,prompt:#7dcfff,pointer:#ff007c"
            colors+=",marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"
            colors+=",border:#565f89"
            ;;
    esac
    
    echo "$colors"
}

# Initialize theme colors
typeset -g TERM_EXPLORER_FZF_COLORS
TERM_EXPLORER_FZF_COLORS=$(_te_get_theme_colors)

# ----------------------------------------------------------------------------
# _te_check_deps: Check if required dependencies are installed
# Returns: 0 if all required deps are present, 1 otherwise
# ----------------------------------------------------------------------------
_te_check_deps() {
    local missing=()
    
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
# _te_preview: Generate preview for file/directory
# Arguments: $1 = item (with icon prefix)
# ----------------------------------------------------------------------------
_te_preview() {
    local selection="$1"
    local item="${selection#* }"  # Remove icon prefix
    
    # Parent directory
    if [[ "$item" == ".." ]]; then
        echo "📁 Parent directory"
        echo ""
        if command -v eza &>/dev/null; then
            eza -la --color=always --icons -- ".." 2>/dev/null | head -20
        else
            ls -la -- ".." 2>/dev/null | head -20
        fi
        return
    fi
    
    # Directory
    if [[ -d "$item" ]]; then
        echo "📁 Directory: $item"
        echo ""
        if command -v eza &>/dev/null; then
            eza -la --color=always --icons -- "$item" 2>/dev/null | head -30
        else
            ls -la -- "$item" 2>/dev/null | head -30
        fi
        return
    fi
    
    # Symbolic link
    if [[ -L "$item" ]]; then
        local target=$(readlink -- "$item" 2>/dev/null)
        echo "🔗 Symbolic link: $item"
        echo "   → $target"
        echo ""
        if [[ -e "$item" ]]; then
            _te_preview "_ $target"
        else
            echo "⚠️  Broken link"
        fi
        return
    fi
    
    # Regular file
    if [[ -f "$item" ]]; then
        local size=$(du -h -- "$item" 2>/dev/null | cut -f1)
        local lines=$(wc -l < "$item" 2>/dev/null | tr -d ' ')
        echo "📄 File: $item"
        echo "   Size: $size | Lines: $lines"
        echo ""
        
        local bat_cmd=$(_te_get_bat)
        if [[ -n "$bat_cmd" ]]; then
            "$bat_cmd" --color=always --style=numbers --line-range=:50 -- "$item" 2>/dev/null
        else
            head -50 -- "$item" 2>/dev/null
        fi
        return
    fi
    
    echo "❓ Unknown item: $item"
}

# Export preview function for fzf subprocess
export -f _te_preview 2>/dev/null || true
export -f _te_get_bat 2>/dev/null || true

# ----------------------------------------------------------------------------
# _te_history_push: Add directory to navigation history
# Arguments: $1 = directory path
# ----------------------------------------------------------------------------
_te_history_push() {
    local dir="$1"
    
    # Don't add duplicates of the last entry
    if [[ ${#_TE_HISTORY[@]} -gt 0 && "${_TE_HISTORY[-1]}" == "$dir" ]]; then
        return
    fi
    
    _TE_HISTORY+=("$dir")
    
    # Limit history size
    if [[ ${#_TE_HISTORY[@]} -gt $_TE_HISTORY_MAX ]]; then
        _TE_HISTORY=("${_TE_HISTORY[@]:1}")
    fi
}

# ----------------------------------------------------------------------------
# _te_history_pop: Get and remove last directory from history
# Returns: Previous directory path or empty
# ----------------------------------------------------------------------------
_te_history_pop() {
    if [[ ${#_TE_HISTORY[@]} -eq 0 ]]; then
        echo ""
        return
    fi
    
    local prev="${_TE_HISTORY[-1]}"
    _TE_HISTORY=("${_TE_HISTORY[@]:0:-1}")
    echo "$prev"
}

# ----------------------------------------------------------------------------
# _te_search_recursive: Recursive file search using fd or find
# Arguments: $1 = search directory
# Returns: Selected file path or empty
# ----------------------------------------------------------------------------
_te_search_recursive() {
    local search_dir="${1:-.}"
    local search_cmd=""
    local result=""
    
    # Prefer fd over find for speed
    if command -v fd &>/dev/null; then
        search_cmd="fd --type f --hidden --follow --exclude .git . '$search_dir'"
    elif command -v fdfind &>/dev/null; then
        search_cmd="fdfind --type f --hidden --follow --exclude .git . '$search_dir'"
    else
        search_cmd="find '$search_dir' -type f -not -path '*/.git/*' 2>/dev/null"
    fi
    
    result=$(eval "$search_cmd" 2>/dev/null | \
        fzf --height=80% \
            --layout=reverse \
            --border=rounded \
            --prompt="🔍 Search: " \
            --header="Recursive file search (Esc to cancel)" \
            --preview="$(_te_get_bat && echo '$(_te_get_bat) --color=always --style=numbers --line-range=:50 -- {}' || echo 'head -50 -- {}')" \
            --preview-window=right:50%:wrap \
            $TERM_EXPLORER_FZF_COLORS \
            --ansi)
    
    echo "$result"
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
            --layout=reverse \
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
            "$editor" -- "$file"
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
                "$bat_cmd" --color=always --style=numbers,header --paging=always -- "$file"
            else
                less -- "$file"
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
                if rm -- "$file" 2>/dev/null; then
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
    local show_preview=${TERM_EXPLORER_PREVIEW:-0}
    local show_hidden=${TERM_EXPLORER_SHOW_HIDDEN:-1}
    
    # Validate directory
    if [[ ! -d "$start_dir" ]]; then
        print -P "%F{red}❌ Directory not found:%f $start_dir"
        return 1
    fi
    
    # Check read permission
    if [[ ! -r "$start_dir" ]]; then
        print -P "%F{red}❌ Permission denied:%f $start_dir"
        return 1
    fi
    
    # Change to initial directory
    cd "$start_dir" || return 1
    
    # Clear navigation history for new session
    _TE_HISTORY=()
    
    local selection
    local item
    
    # Main navigation loop
    while true; do
        # Count items for header
        local file_list=$(_te_list "$show_hidden")
        local item_count=$(echo "$file_list" | wc -l | tr -d ' ')
        # Subtract 1 for parent dir ".." entry (if not at root)
        [[ "$PWD" != "/" ]] && ((item_count--))
        
        # Build status indicators
        local hidden_status="[H:$([ "$show_hidden" -eq 1 ] && echo 'ON' || echo 'OFF')]"
        local preview_status="[P:$([ "$show_preview" -eq 1 ] && echo 'ON' || echo 'OFF')]"
        local history_count="[←:${#_TE_HISTORY[@]}]"
        
        # Build header with keyboard shortcuts
        local header="╭──────────────────────────────────────────────────────────────────────────────────╮
│ Enter: Select │ Esc: Exit │ ^R: Refresh │ ^H: Parent │ M-.: Hidden │ ^P: Preview │
│ ^O: Go Back   │ ^F: Search                                                       │
╰──────────────────────────────────────────────────────────────────────────────────╯
 📂 $PWD
 📊 $item_count items  $hidden_status $preview_status $history_count"

        # Build preview command
        local preview_cmd=""
        local preview_window=""
        if [[ "$show_preview" -eq 1 ]]; then
            local bat_cmd=$(_te_get_bat)
            if [[ -n "$bat_cmd" ]]; then
                preview_cmd="item={};item=\${item#* };if [[ -d \"\$item\" ]];then echo '📁 Directory:' \"\$item\";echo;eza -la --color=always -- \"\$item\" 2>/dev/null || ls -la -- \"\$item\" 2>/dev/null | head -30;elif [[ -f \"\$item\" ]];then $bat_cmd --color=always --style=numbers --line-range=:50 -- \"\$item\" 2>/dev/null;else echo '🔗 '\"\$item\";fi"
            else
                preview_cmd="item={};item=\${item#* };if [[ -d \"\$item\" ]];then echo '📁 Directory:' \"\$item\";echo;ls -la -- \"\$item\" 2>/dev/null | head -30;elif [[ -f \"\$item\" ]];then head -50 -- \"\$item\" 2>/dev/null;else echo '🔗 '\"\$item\";fi"
            fi
            preview_window="right:50%:wrap"
        fi

        # Run fzf with dynamic options
        local fzf_opts=(
            --height=80%
            --layout=reverse
            --border=rounded
            --prompt="❯ "
            --header="$header"
            --header-lines=0
            --bind="ctrl-r:reload(_te_list $show_hidden)"
            --bind="ctrl-h:become(echo 'ctrl-h'$'\\n''📁 ..')"
            --expect="ctrl-h,alt-.,ctrl-p,ctrl-o,ctrl-f"
            $TERM_EXPLORER_FZF_COLORS
            --ansi
        )
        
        if [[ -n "$preview_cmd" ]]; then
            fzf_opts+=(--preview="$preview_cmd" --preview-window="$preview_window")
        fi
        
        selection=$(echo "$file_list" | fzf "${fzf_opts[@]}")
        
        local fzf_exit=$?
        
        # Parse fzf output (first line is expected key, second is selection)
        local expected_key=$(echo "$selection" | head -1)
        selection=$(echo "$selection" | tail -1)
        
        # Handle Alt-. (toggle hidden files)
        if [[ "$expected_key" == "alt-." ]]; then
            if [[ "$show_hidden" -eq 1 ]]; then
                show_hidden=0
                print -P "%F{yellow}🙈 Hidden files: OFF%f"
            else
                show_hidden=1
                print -P "%F{green}👁 Hidden files: ON%f"
            fi
            sleep 0.3
            continue
        fi
        
        # Handle Ctrl-P (toggle preview)
        if [[ "$expected_key" == "ctrl-p" ]]; then
            if [[ "$show_preview" -eq 1 ]]; then
                show_preview=0
                print -P "%F{yellow}📄 Preview: OFF%f"
            else
                show_preview=1
                print -P "%F{green}👁 Preview: ON%f"
            fi
            sleep 0.3
            continue
        fi
        
        # Handle Ctrl-O (go back in history)
        if [[ "$expected_key" == "ctrl-o" ]]; then
            local prev_dir=$(_te_history_pop)
            if [[ -n "$prev_dir" && -d "$prev_dir" ]]; then
                cd "$prev_dir"
                print -P "%F{blue}⬅️  Back to:%f $prev_dir"
                sleep 0.3
            else
                print -P "%F{yellow}📭 No more history%f"
                sleep 0.5
            fi
            continue
        fi
        
        # Handle Ctrl-F (recursive search)
        if [[ "$expected_key" == "ctrl-f" ]]; then
            local search_result=$(_te_search_recursive ".")
            if [[ -n "$search_result" ]]; then
                # Navigate to file's directory and select the file
                local file_dir=$(dirname "$search_result")
                local file_name=$(basename "$search_result")
                if [[ -d "$file_dir" ]]; then
                    _te_history_push "$PWD"
                    cd "$file_dir"
                    if [[ -f "$file_name" ]]; then
                        _te_actions "$file_name"
                    fi
                fi
            fi
            continue
        fi
        
        # Handle Ctrl-H
        if [[ "$expected_key" == "ctrl-h" || "$selection" == "📁 .." ]]; then
            if [[ "$PWD" != "/" ]]; then
                _te_history_push "$PWD"
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
            if [[ "$PWD" != "/" ]]; then
                _te_history_push "$PWD"
                cd ..
            fi
            
        elif [[ -d "$item" ]]; then
            # Check read permission before entering
            if [[ -r "$item" ]]; then
                _te_history_push "$PWD"
                cd -- "$item"
            else
                print -P "%F{red}❌ Permission denied:%f $item"
                sleep 1
            fi
            
        elif [[ -f "$item" ]]; then
            # Show action menu for file
            _te_actions "$item"
            
        elif [[ -L "$item" ]]; then
            # Handle symbolic link with depth limit to prevent circular loops
            local link_target
            local depth=0
            local max_depth=10
            local current="$item"
            
            # Resolve symlink chain with depth limit
            while [[ -L "$current" && $depth -lt $max_depth ]]; do
                link_target=$(readlink "$current" 2>/dev/null)
                # Handle relative symlinks
                if [[ "$link_target" != /* ]]; then
                    link_target="$(dirname "$current")/$link_target"
                fi
                current="$link_target"
                ((depth++))
            done
            
            if [[ $depth -ge $max_depth ]]; then
                print -P "%F{red}❌ Circular or too deep symlink:%f $item"
                sleep 1
            elif [[ -d "$current" ]]; then
                if [[ -r "$current" ]]; then
                    _te_history_push "$PWD"
                    cd -- "$item"
                else
                    print -P "%F{red}❌ Permission denied:%f $item"
                    sleep 1
                fi
            elif [[ -f "$current" ]]; then
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
    Alt-.       Toggle hidden files visibility
    Ctrl-P      Toggle preview panel
    Ctrl-O      Go back to previous directory
    Ctrl-F      Recursive file search
    ↑/↓         Navigate list
    Type        Fuzzy search filter

FILE ACTIONS:
    📝 Edit         Open file in $EDITOR
    📋 Copy path    Copy absolute or relative path to clipboard
    👁  View         View file content with pager
    🗑️  Delete       Delete file (with confirmation)

CONFIGURATION:
    TERM_EXPLORER_SHOW_HIDDEN=1    Show hidden files (default: 1)
    TERM_EXPLORER_PREVIEW=0        Show preview panel (default: 0)
    TERM_EXPLORER_THEME=tokyo-night  Color theme
    EDITOR=vim                     Editor for file editing

AVAILABLE THEMES:
    tokyo-night (default), dracula, nord, gruvbox, catppuccin, monokai

DEPENDENCIES:
    Required: fzf
    Optional: bat (syntax highlighting), eza (modern ls), fd (fast search)

EXAMPLES:
    te                              Open explorer in current directory
    te ~/projects                   Open explorer in ~/projects
    te /var/log                     Open explorer in /var/log
    
    TERM_EXPLORER_THEME=dracula te  Use Dracula theme
    TERM_EXPLORER_PREVIEW=1 te      Start with preview enabled

EOF
}
