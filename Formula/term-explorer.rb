# Homebrew Formula for term-explorer
#
# Installation:
#   brew install term-explorer
#
# Or from a local file:
#   brew install ./Formula/term-explorer.rb
#

class TermExplorer < Formula
  desc "Interactive file explorer for Zsh with fuzzy search"
  homepage "https://github.com/lucas-moraes/term-explorer"
  url "https://github.com/lucas-moraes/term-explorer/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "placeholder_hash_will_be_generated"
  license "MIT"
  head "https://github.com/lucas-moraes/term-explorer.git", branch: "main"

  depends_on "fzf"
  depends_on "zsh"

  def install
    # Install main script
    libexec.install "term-explorer.zsh"

    # Install CLI wrapper for term-explorer
    (bin/"te").write <<~EOS
      #!/usr/bin/env zsh
      CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/term-explorer"
      SCRIPT="#{libexec}/term-explorer.zsh"

      if [ ! -f "$SCRIPT" ]; then
        printf '%s\n' "term-explorer: script not found at $SCRIPT" >&2
        exit 1
      fi

      source "$SCRIPT"

      if typeset -f term-explorer >/dev/null 2>&1 || whence term-explorer >/dev/null 2>&1; then
        term-explorer "$@"
      else
        printf '%s\n' "term-explorer: main function not found after sourcing $SCRIPT" >&2
        exit 1
      fi
    EOS

    # Install helper scripts
    prefix.install "install.sh"
    prefix.install "uninstall.sh"
    prefix.install "update.sh"
    prefix.install "Makefile"

    # Install README and license
    prefix.install "README.md"
    prefix.install "LICENSE"
  end

  test do
    system "zsh", "-n", "#{libexec}/term-explorer.zsh"
  end

  caveats <<~EOS
    The 'te' command is now available.
    
    Run 'te' or 'te <directory>' to start the file explorer.

    For manual sourcing in your ~/.zshrc (optional):
      source #{libexec}/term-explorer.zsh

    To update, run:
      #{prefix}/update.sh

    To uninstall, run:
      #{prefix}/uninstall.sh
  EOS
end
