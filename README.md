# Term-Explorer

Interactive file explorer for Zsh with fuzzy search powered by [fzf](https://github.com/junegunn/fzf).

![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-zsh-yellow.svg)

```
╭──────────────────────────────────────────────────────────────────────────────────╮
│ Enter: Select │ Esc: Exit │ ^R: Refresh │ ^H: Parent │ M-.: Hidden │ ^P: Preview │
│ ^O: Go Back   │ ^F: Search                                                       │
╰──────────────────────────────────────────────────────────────────────────────────╯
 📂 ~/projects/term-explorer
 📊 7 items  [H:ON] [P:OFF] [←:0]

   📁 ..
   📁 docs/
   📁 src/
 ❯ 📝 README.md
   📋 package.json
   🐚 install.sh
   📜 LICENSE

```

## Features

- **Fuzzy Search**: Lightning-fast file filtering with fzf
- **File Icons**: Visual file type identification with emoji icons
- **Deep Navigation**: Seamlessly navigate into directories
- **Action Menu**: Edit, copy path, view, or delete files
- **Toggle Preview**: Optional file preview panel (Ctrl-P)
- **Toggle Hidden Files**: Show/hide hidden files on the fly (Ctrl-.)
- **Navigation History**: Go back to previous directories (Ctrl-O)
- **Recursive Search**: Find files anywhere in the tree (Ctrl-F)
- **Theme Support**: 6 beautiful color themes (Tokyo Night, Dracula, Nord, Gruvbox, Catppuccin, Monokai)
- **Cross-Platform**: Works on macOS, Linux, and WSL
- **Zero Config**: Works out of the box
- **Robust**: Handles spaces in filenames, permission errors, and circular symlinks

## Requirements

### Required

- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

### Optional

- [bat](https://github.com/sharkdp/bat) - Syntax highlighting for file preview and viewing
- [fd](https://github.com/sharkdp/fd) - Faster recursive file search (Ctrl-F)

## Installation

### Quick Install (Recommended)

```bash
git clone https://github.com/YOUR_USERNAME/term-explorer.git
cd term-explorer
./install.sh
```

### Manual Install

1. Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/term-explorer.git ~/.config/term-explorer
```

2. Add to your `.zshrc`:

```bash
echo 'source ~/.config/term-explorer/term-explorer.zsh' >> ~/.zshrc
```

3. Reload your shell:

```bash
source ~/.zshrc
```

### Installing Dependencies

#### macOS (Homebrew)

```bash
brew install fzf

# Optional: for enhanced features
brew install bat fd
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install fzf

# Optional: for enhanced features
# Note: On Debian/Ubuntu, bat may be installed as 'batcat', fd as 'fdfind'
sudo apt install bat fd-find
```

#### Arch Linux

```bash
sudo pacman -S fzf

# Optional: for enhanced features
sudo pacman -S bat fd
```

#### Fedora

```bash
sudo dnf install fzf

# Optional: for enhanced features
sudo dnf install bat fd-find
```

## Usage

### Basic Commands

```bash
# Open explorer in current directory
term-explorer

# Use the short alias
te

# Open in a specific directory
te ~/projects
te /var/log
```

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Enter` | Enter directory / Open action menu for files |
| `Esc` | Exit explorer |
| `Ctrl-R` | Refresh file list |
| `Ctrl-H` | Go to parent directory |
| `Alt-.` | Toggle hidden files visibility |
| `Ctrl-P` | Toggle preview panel |
| `Ctrl-O` | Go back to previous directory |
| `Ctrl-F` | Recursive file search |
| `↑` / `↓` | Navigate list |
| Type | Fuzzy search filter |

### File Actions Menu

When you select a file, an action menu appears:

| Action | Description |
|--------|-------------|
| Edit | Open file in `$EDITOR` (defaults to vim) |
| Copy absolute path | Copy full path to clipboard |
| Copy relative path | Copy relative path to clipboard |
| View | Open file in pager (less/bat) |
| Delete | Delete file (requires typing 'yes' to confirm) |

## Configuration

### Environment Variables

```bash
# Show/hide hidden files (default: 1 = show)
export TERM_EXPLORER_SHOW_HIDDEN=1

# Enable preview panel by default (default: 0 = off)
export TERM_EXPLORER_PREVIEW=1

# Set color theme (default: tokyo-night)
export TERM_EXPLORER_THEME="dracula"

# Set your preferred editor
export EDITOR=nvim
```

### Available Themes

| Theme | Description |
|-------|-------------|
| `tokyo-night` | Default dark theme with purple accents |
| `dracula` | Classic Dracula dark theme |
| `nord` | Cool, bluish Arctic-inspired theme |
| `gruvbox` | Retro groove colors |
| `catppuccin` | Soothing pastel theme |
| `monokai` | Classic code editor theme |

Example usage:

```bash
# Use Dracula theme for this session
TERM_EXPLORER_THEME=dracula te

# Or set permanently in .zshrc
export TERM_EXPLORER_THEME="nord"
```

## File Icons

Term-explorer automatically assigns icons based on file type:

| Icon | Type |
|------|------|
| 📁 | Directory |
| 🔗 | Symbolic link |
| 🐚 | Shell script |
| 🐍 | Python |
| 📜 | JavaScript |
| 💠 | TypeScript |
| 📋 | JSON |
| ⚙️  | YAML/TOML |
| 📝 | Markdown |
| 🐳 | Docker |
| 📦 | Archive |
| 🖼️  | Image |
| 🎵 | Audio |
| 🎬 | Video |
| 🔐 | Environment file |
| ⚡ | Executable |

## Troubleshooting

### "fzf not found"

Install fzf using your package manager:

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Or install from git
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### View action not showing syntax highlighting

Install bat for enhanced file viewing:

```bash
# macOS
brew install bat

# Ubuntu/Debian (may install as 'batcat')
sudo apt install bat
```

### Clipboard not working

Install a clipboard tool:

```bash
# Linux X11
sudo apt install xclip
# or
sudo apt install xsel

# Linux Wayland
sudo apt install wl-clipboard
```

### Icons not displaying correctly

Make sure your terminal supports Unicode/emoji. For best results, use a modern terminal emulator like:
- iTerm2 (macOS)
- Alacritty
- Kitty
- Windows Terminal

## Helper Commands

```bash
# Show version
term-explorer-version

# Show help
term-explorer-help
```

## Uninstallation

```bash
# Remove the source line from .zshrc
# Then delete the installation directory
rm -rf ~/.config/term-explorer
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [fzf](https://github.com/junegunn/fzf) - The amazing fuzzy finder
- [bat](https://github.com/sharkdp/bat) - A cat clone with wings
- [eza](https://github.com/eza-community/eza) - A modern replacement for ls
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Color theme inspiration

---

Made with terminal love by developers, for developers.
