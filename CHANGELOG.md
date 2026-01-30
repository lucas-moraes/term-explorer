# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-01-30

### Added

- **Installation Methods** - Multiple ways to install term-explorer:
  - Oh-My-Zsh plugin support
  - Homebrew formula
  - AUR package (Arch Linux)
  - Makefile with install/uninstall targets
- **Scripts**:
  - `update.sh` - Self-update from git repository
  - `uninstall.sh` - Clean removal with bookmarks backup option
- **CI/CD Pipeline** - GitHub Actions workflow:
  - ShellCheck linting
  - Syntax validation
  - Installation/uninstallation tests
  - Security scanning with Trivy

### Changed

- Version bumped to 2.1.0
- Installation instructions updated with all available methods
- Uninstallation improved with bookmarks backup
- Preview panel now enabled by default (TERM_EXPLORER_PREVIEW=1)

## [2.0.0] - 2026-01-30

### Added

- **Bookmarks System** (Ctrl-B):
  - Open bookmarks menu to quickly navigate to saved directories
  - Press Ctrl-D on a bookmark to remove it
  - Bookmarks stored in `~/.config/term-explorer/bookmarks`
- **Quick Actions Menu** (Ctrl-Q):
  - Create new files and directories
  - Rename any file or directory
  - Move items to another location
  - Copy items to another location
- **Directory Actions Menu**:
  - Rename directories
  - Copy absolute/relative path
  - Delete directories with confirmation

### Changed

- Directory selection now opens action menu instead of directly entering
- Users can choose to enter directory from action menu
- Version bumped to 2.0.0

## [1.2.0] - 2026-01-29

### Added

- **New keyboard shortcuts:**
  - `Alt-.` - Toggle hidden files visibility on/off
  - `Ctrl-P` - Toggle preview panel on/off
  - `Ctrl-O` - Go back to previous directory (navigation history)
  - `Ctrl-F` - Recursive file search (uses `fd` if available, falls back to `find`)
- **Item counter** - Header now shows total number of items in current directory
- **Status indicators** - Header shows [H:ON/OFF] for hidden files, [P:ON/OFF] for preview, [←:N] for history depth
- **Theme presets** - 6 color themes available via `TERM_EXPLORER_THEME`:
  - `tokyo-night` (default)
  - `dracula`
  - `nord`
  - `gruvbox`
  - `catppuccin`
  - `monokai`
- **Navigation history** - Stores up to 50 visited directories per session
- **Preview panel** - Optional file/directory preview with syntax highlighting (toggle with Ctrl-P)
- New configuration option `TERM_EXPLORER_PREVIEW` to start with preview enabled

### Changed

- Version bumped to 1.2.0
- Header redesigned to show all available shortcuts
- Help command updated with new features and examples

### Dependencies

- Optional: `fd` or `fdfind` (faster recursive search)

## [1.1.0] - 2026-01-29

### Changed

- Removed unused functions: `_te_preview`, `_te_get_file_size` (preview was removed in previous update)
- Removed unused variables: `initial_dir`, `original_dir`
- README.md: Translated Portuguese text to English in ASCII demo
- README.md: Updated demo to reflect current interface (no preview panel)
- README.md: Fixed documentation stating 'sim' when code uses 'yes' for delete confirmation

### Fixed

- Added `--` to commands to properly handle files starting with dashes
- Added read permission check before entering directories
- Added circular symlink detection with depth limit (max 10 levels)
- Improved quoting for filenames with spaces and special characters

### Security

- Delete confirmation now properly validates user input

## [1.0.0] - 2026-01-29

### Added

- Initial release of term-explorer
- Interactive file navigation with fzf fuzzy search
- Syntax highlighted file preview with bat/batcat
- Modern directory listing with eza
- File action menu:
  - Edit file in $EDITOR
  - Copy absolute path to clipboard
  - Copy relative path to clipboard
  - View file content with pager
  - Delete file with confirmation
- Keyboard shortcuts:
  - `Enter` - Select item / Open action menu
  - `Esc` - Exit explorer
  - `Ctrl-R` - Refresh file list
  - `Ctrl-H` - Go to parent directory
- Tokyo Night color theme
- Cross-platform clipboard support (macOS, Linux X11, Wayland, WSL, Termux)
- Automatic fallbacks when optional dependencies are missing
- File type icons based on extension
- Hidden files support (configurable)
- Installation script for easy setup
- Comprehensive documentation

### Dependencies

- Required: fzf
- Optional: bat/batcat, eza

### Supported Platforms

- macOS
- Linux (Ubuntu, Debian, Arch, Fedora, Alpine)
- Windows WSL
- Termux (Android)
