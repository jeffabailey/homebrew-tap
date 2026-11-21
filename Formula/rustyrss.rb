class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.2/rustyrss-0.1.2-macos-arm64.tar.gz"
  version "0.1.2"
  sha256 "7d97fb960481ac7c968ca58e1578689ef64019f2df997d03ab5b8b9d81a5de28"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit ab6828a.
  depends_on arch: :arm64

  on_linux do
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.2/rustyrss-0.1.2-linux-arm64.tar.gz"
      sha256 "238d52365cd083fc154274b2d6a2386053fbb7e6da10591a9d850b2a0988d414"
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
