# Term-Explorer

Interactive file explorer for Zsh with fuzzy search powered by [fzf](https://github.com/junegunn/fzf).

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-zsh-yellow.svg)

```
╭────────────────────────────────────────────────────────────────╮
│  Enter: Selecionar │ Esc: Sair │ ^R: Atualizar │ ^H: Subir    │
╰────────────────────────────────────────────────────────────────╯
📂 ~/projects/term-explorer
                                    │
  📁 ..                             │  📄 Arquivo: README.md
  📁 docs/                          │  📊 Tamanho: 4.2K
  📁 src/                           │  ────────────────────────
❯ 📝 README.md                      │  # Term-Explorer
  📋 package.json                   │
  🐚 install.sh                     │  Interactive file explorer
  📜 LICENSE                        │  for Zsh...
                                    │
```

## Features

- **Fuzzy Search**: Lightning-fast file filtering with fzf
- **Syntax Highlighting**: File preview with bat/batcat
- **Modern Listing**: Directory preview with eza
- **Deep Navigation**: Seamlessly navigate into directories
- **Action Menu**: Edit, copy path, view, or delete files
- **Cross-Platform**: Works on macOS, Linux, and WSL
- **Tokyo Night Theme**: Beautiful dark color scheme
- **Zero Config**: Works out of the box

## Requirements

### Required

- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

### Optional (Recommended)

- [bat](https://github.com/sharkdp/bat) - Syntax highlighting for file preview
- [eza](https://github.com/eza-community/eza) - Modern replacement for ls

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
brew install fzf bat eza
```

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install fzf bat eza

# Note: On Debian/Ubuntu, bat may be installed as 'batcat'
# The script handles this automatically
```

#### Arch Linux

```bash
sudo pacman -S fzf bat eza
```

#### Fedora

```bash
sudo dnf install fzf bat eza
```

#### Alpine Linux

```bash
apk add fzf bat eza
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
| Delete | Delete file (requires typing 'sim' to confirm) |

## Configuration

### Environment Variables

```bash
# Show/hide hidden files (default: 1 = show)
export TERM_EXPLORER_SHOW_HIDDEN=1

# Set your preferred editor
export EDITOR=nvim
```

### Customizing Colors

The script uses the Tokyo Night color theme by default. To customize, modify the `TERM_EXPLORER_FZF_COLORS` variable in `term-explorer.zsh`:

```bash
typeset -g TERM_EXPLORER_FZF_COLORS="--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7"
# ... add your custom colors
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

### Preview not showing syntax highlighting

Install bat:

```bash
# macOS
brew install bat

# Ubuntu/Debian (may install as 'batcat')
sudo apt install bat
```

### Directory listing looks basic

Install eza:

```bash
# macOS
brew install eza

# Ubuntu/Debian
sudo apt install eza

# Or via cargo
cargo install eza
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

Make sure you're using a [Nerd Font](https://www.nerdfonts.com/) in your terminal:

```bash
# macOS
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

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
