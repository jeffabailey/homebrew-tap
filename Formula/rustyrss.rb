class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.1/rustyrss-0.1.1-macos-arm64.tar.gz"
  version "0.1.1"
  sha256 "3cbb537ee76d039d822c17c17648e01bb814fdb327aa4e79124d273cc97b4611"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit daf1619.
  depends_on arch: :arm64

  on_linux do
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.1/rustyrss-0.1.1-linux-arm64.tar.gz"
      sha256 "1bb31dd6fbe0ad8425f10a8e622c4475465d40fb3cf915467b02da60e4f71f01"
    end
  end

  def install
    bin.install "rustyrss-server", "rustyrss-tui"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rustyrss-tui --version")
    assert_path_exists bin/"rustyrss-server"
  end
end
