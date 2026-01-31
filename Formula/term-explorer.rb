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
  homepage "https://github.com/YOUR_USERNAME/term-explorer"
  url "https://github.com/YOUR_USERNAME/term-explorer/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "placeholder_hash_will_be_generated"
  license "MIT"
  head "https://github.com/YOUR_USERNAME/term-explorer.git", branch: "main"

  depends_on "fzf"
  depends_on "zsh"

  def install
    # Install main script to config directory
    config_dir = Dir.home / ".config" / "term-explorer"
    config_dir.mkpath
    cp "term-explorer.zsh", config_dir

    # Install scripts
    bin.install_symlink config_dir / "term-explorer.zsh" => "te"

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
    system "zsh", "-n", "#{prefix}/.config/term-explorer/term-explorer.zsh"
  end

  caveats <<~EOS
    Add the following to your ~/.zshrc:

      source #{Dir.home}/.config/term-explorer/term-explorer.zsh

    Then restart your shell or run:

      source ~/.zshrc

    To update, run:

      term-explorer-update
      # or
      #{prefix}/update.sh

    To uninstall, run:

      #{prefix}/uninstall.sh
  EOS
end
