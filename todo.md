# Term-Explorer Roadmap

This document outlines planned improvements, bug fixes, and new features for term-explorer.

## Table of Contents

- [Phase 1: Critical Fixes](#phase-1-critical-fixes)
- [Phase 2: UX Improvements](#phase-2-ux-improvements)
- [Phase 3: Advanced Features](#phase-3-advanced-features)
- [Phase 4: Distribution & CI](#phase-4-distribution--ci)
- [Contributing](#contributing)

---

## Phase 1: Critical Fixes

### 1.1 Dead Code Cleanup

| Priority | Issue | Status |
|----------|-------|--------|
| High | Functions `_te_preview`, `_te_get_bat`, `_te_get_file_size` unused after preview removal | Pending |
| High | Warnings for `bat/eza` in `_te_check_deps` no longer relevant without preview | Pending |
| Medium | Unused variables: `initial_dir`, `original_dir` in main function | Pending |

**Solution Options:**
- **Option A**: Remove all preview-related code
- **Option B**: Make preview optional with `--preview` flag or `Ctrl-P` toggle (recommended)

### 1.2 README.md Fixes

| Priority | Issue | Status |
|----------|-------|--------|
| High | ASCII demo shows preview panel that was removed | Pending |
| High | Portuguese text in demo: "Selecionar", "Sair", "Atualizar", "Subir" | Pending |
| High | States "requires typing 'sim'" but code uses 'yes' | Pending |
| Medium | `YOUR_USERNAME` placeholder in repository URLs | Pending |

### 1.3 Robustness Fixes

| Priority | Issue | Solution | Status |
|----------|-------|----------|--------|
| High | Files with spaces in name may break | Add proper quoting around `$item` | Pending |
| High | Special characters in filenames | Escape characters in `_te_actions` | Pending |
| Medium | Directories without read permission | Add `[[ -r "$item" ]]` check | Pending |
| Medium | Circular symlinks may cause infinite loop | Limit resolution depth | Pending |
| Low | Terminal without Unicode support | ASCII icon fallback | Pending |

---

## Phase 2: UX Improvements

### 2.1 New Keyboard Shortcuts

| Shortcut | Action | Priority | Status |
|----------|--------|----------|--------|
| `Ctrl-.` | Toggle hidden files visibility | High | Pending |
| `Ctrl-P` | Toggle preview panel | High | Pending |
| `Ctrl-O` | Go back to previous directory | Medium | Pending |
| `Ctrl-B` | Open bookmarks | Medium | Pending |
| `Ctrl-F` | Recursive file search | Low | Pending |

### 2.2 Interface Enhancements

| Feature | Description | Priority | Status |
|---------|-------------|----------|--------|
| Item counter | Show "42 items" in header | Medium | Pending |
| Loading indicator | Spinner for large directories | Medium | Pending |
| Theme presets | `TERM_EXPLORER_THEME` variable with options | Medium | Pending |
| Dynamic header | Adjust to terminal width | Low | Pending |

### 2.3 Theme Options

```bash
# Proposed theme configuration
export TERM_EXPLORER_THEME="tokyo-night"  # default
# Options: tokyo-night, dracula, nord, gruvbox, catppuccin, monokai
```

---

## Phase 3: Advanced Features

### 3.1 Optional Preview Panel

Reintroduce preview as an optional feature:

```bash
# Toggle with Ctrl-P or start with preview enabled
te --preview
te -p

# Configuration
export TERM_EXPLORER_PREVIEW=1  # Enable by default
```

### 3.2 Navigation History

```bash
# Ctrl-O: Go back to previous directory
# Stores last 10 visited directories in session
```

### 3.3 Bookmarks System

```bash
# Ctrl-B: Open bookmarks menu
# Ctrl-D: Add current directory to bookmarks

# Bookmarks stored in ~/.config/term-explorer/bookmarks
```

### 3.4 Multi-Select Mode

```bash
# Tab: Toggle selection on current item
# Ctrl-A: Select all
# Enter: Open action menu for selected items

# Batch actions:
# - Delete multiple files
# - Copy multiple paths
# - Move files (new action)
```

### 3.5 Quick Actions

| Action | Description | Priority |
|--------|-------------|----------|
| Create file | `touch` new file | Medium |
| Create directory | `mkdir` new directory | Medium |
| Rename | Rename file/directory | Medium |
| Move | Move file to another location | Low |
| Copy file | Duplicate file | Low |

### 3.6 Recursive Search

```bash
# Ctrl-F: Enter search mode
# Uses fd or find to search recursively
# Results shown in fzf with path
```

---

## Phase 4: Distribution & CI

### 4.1 Installation Methods

| Method | Status |
|--------|--------|
| Manual install | Done |
| install.sh script | Done |
| Oh-My-Zsh plugin | Pending |
| Zinit plugin | Pending |
| Antigen plugin | Pending |
| Homebrew formula | Pending |
| AUR package | Pending |

#### Oh-My-Zsh Plugin Structure

```
~/.oh-my-zsh/custom/plugins/term-explorer/
├── term-explorer.plugin.zsh
└── term-explorer.zsh
```

#### Zinit Installation

```bash
zinit light username/term-explorer
```

### 4.2 Scripts to Add

| Script | Purpose | Status |
|--------|---------|--------|
| `uninstall.sh` | Clean removal | Pending |
| `Makefile` | Install/uninstall targets | Pending |
| `update.sh` | Self-update from git | Pending |

### 4.3 CI/CD Pipeline

| Task | Tool | Status |
|------|------|--------|
| Shell linting | ShellCheck | Pending |
| Syntax validation | `zsh -n` | Pending |
| Unit tests | bats-core | Pending |
| Integration tests | Docker | Pending |
| Release automation | GitHub Actions | Pending |

#### Proposed GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: '.'
          
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y zsh fzf
      - name: Syntax check
        run: zsh -n term-explorer.zsh
```

---

## Performance Optimizations

| Issue | Solution | Priority |
|-------|----------|----------|
| `_te_get_icon` called per file | Cache icons or use `eza --icons` | Medium |
| Multiple loops in `_te_list` | Consolidate into single loop | Medium |
| Repeated `command -v` calls | Cache results at initialization | Low |

### Proposed Icon Caching

```zsh
# Initialize icon cache once
typeset -gA _TE_ICON_CACHE
_te_init_icons() {
    _TE_ICON_CACHE=(
        [sh]="🐚" [py]="🐍" [js]="📜" [ts]="💠"
        # ... etc
    )
}
```

---

## Configuration Options

### Current Configuration

```bash
TERM_EXPLORER_SHOW_HIDDEN=1    # Show hidden files
EDITOR=vim                      # Editor for files
```

### Proposed Additional Options

```bash
# Display
TERM_EXPLORER_THEME="tokyo-night"      # Color theme
TERM_EXPLORER_ICONS=1                   # Show file icons (1=emoji, 2=nerd-font, 0=none)
TERM_EXPLORER_PREVIEW=0                 # Show preview panel
TERM_EXPLORER_PREVIEW_POSITION="right"  # Preview position (right, bottom)

# Behavior
TERM_EXPLORER_CONFIRM_DELETE=1          # Require confirmation for delete
TERM_EXPLORER_FOLLOW_SYMLINKS=1         # Follow symlinks when navigating
TERM_EXPLORER_SORT="name"               # Sort order (name, size, date, type)

# Performance
TERM_EXPLORER_MAX_FILES=1000            # Max files to display (0=unlimited)
```

---

## Contributing

We welcome contributions! Here's how you can help:

### Priority Areas

1. **Bug fixes** - See Phase 1 issues
2. **Documentation** - README improvements, translations
3. **New features** - See Phase 2-3 features
4. **Testing** - Add test coverage

### How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run syntax check: `zsh -n term-explorer.zsh`
5. Commit with descriptive message
6. Push and open a Pull Request

### Code Style

- Use 4 spaces for indentation
- Add comments for complex logic
- Follow existing naming conventions (`_te_` prefix for internal functions)
- Document functions with header comments

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-29 | Initial release |
| 1.1.0 | TBD | Phase 1 fixes |
| 1.2.0 | TBD | Phase 2 UX improvements |
| 2.0.0 | TBD | Phase 3 advanced features |

---

## License

MIT License - See [LICENSE](LICENSE) for details.
