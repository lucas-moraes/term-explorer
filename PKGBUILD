# Maintainer: YOUR_NAME <your@email.com>
# Contributor: term-explorer contributors

pkgname=term-explorer
pkgver=2.1.0
pkgrel=1
pkgdesc="Interactive file explorer for Zsh with fuzzy search"
arch=('any')
url="https://github.com/YOUR_USERNAME/term-explorer"
license=('MIT')
depends=('zsh' 'fzf')
optdepends=('bat: Syntax highlighting for file preview'
            'fd: Faster recursive search')
source=("${pkgname}-${pkgver}.tar.gz::${url}/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('SKIP')

package() {
  cd "${srcdir}/${pkgname}-${pkgver}"

  # Install main script
  install -Dm644 term-explorer.zsh "$pkgdir/usr/share/term-explorer/term-explorer.zsh"

  # Install wrapper script
  install -Dm755 <(cat <<'EOF'
#!/usr/bin/env zsh
source /usr/share/term-explorer/term-explorer.zsh "$@"
EOF
  ) "$pkgdir/usr/bin/te"

  # Install helper scripts
  install -Dm755 install.sh "$pkgdir/usr/share/term-explorer/install.sh"
  install -Dm755 uninstall.sh "$pkgdir/usr/share/term-explorer/uninstall.sh"
  install -Dm755 update.sh "$pkgdir/usr/share/term-explorer/update.sh"
  install -Dm644 Makefile "$pkgdir/usr/share/term-explorer/Makefile"

  # Install documentation
  install -Dm644 README.md "$pkgdir/usr/share/doc/term-explorer/README.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/term-explorer/LICENSE"

  # Install Zsh completion (if available)
  if [ -f "term-explorer.zsh-completion" ]; then
    install -Dm644 term-explorer.zsh-completion "$pkgdir/usr/share/zsh/vendor-completions/_te"
  fi
}
