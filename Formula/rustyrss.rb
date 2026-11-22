class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.5/rustyrss-0.1.5-macos-arm64.tar.gz"
  version "0.1.5"
  sha256 "233760ad05215a729c764ed0d1ca76eb2de5511f9b7317c6f7a827bba9419d20"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit d19b21c.
  depends_on arch: :arm64

  on_linux do
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.5/rustyrss-0.1.5-linux-arm64.tar.gz"
      sha256 "31bae734eda360c66f2fc878960da3e759acf51efb71bff794eb2acd7e21341d"
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
