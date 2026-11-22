class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.4/rustyrss-0.1.4-macos-arm64.tar.gz"
  version "0.1.4"
  sha256 "4e58fef8ca4c20c51abfddb042bd3303e06f47d7e544a1ee2f22d2e6eb1bfb3a"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit 2eb0b72.
  depends_on arch: :arm64

  on_linux do
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.4/rustyrss-0.1.4-linux-arm64.tar.gz"
      sha256 "19b4a43fc3f7c916e9b7ee24f058579317927623084cc7b231c0a78e31f7c4bf"
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
