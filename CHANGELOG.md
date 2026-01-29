# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
