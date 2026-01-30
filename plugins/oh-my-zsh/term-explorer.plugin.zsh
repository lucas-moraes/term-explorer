# term-explorer.plugin.zsh - Oh-My-Zsh Plugin
# Sourced automatically by Oh-My-Zsh

# Source the main script
if [[ -f "${0:A:h}/term-explorer.zsh" ]]; then
    source "${0:A:h}/term-explorer.zsh"
else
    # Fallback to installation directory
    if [[ -f "$HOME/.config/term-explorer/term-explorer.zsh" ]]; then
        source "$HOME/.config/term-explorer/term-explorer.zsh"
    else
        print -P "%F{red}term-explorer plugin: main script not found%f"
        print -P "%F{yellow}Install term-explorer to ~/.config/term-explorer or use the plugin path directly%f"
    fi
fi
