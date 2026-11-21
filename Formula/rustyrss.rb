class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.3/rustyrss-0.1.3-macos-arm64.tar.gz"
  version "0.1.3"
  sha256 "21bf843c1c1bfa80e5671f9a8ac70f571e9be8c1d3e80ff8fc98f193418bbed0"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit c12f29b.
  depends_on arch: :arm64

  on_linux do
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.3/rustyrss-0.1.3-linux-arm64.tar.gz"
      sha256 "a059487dff33b00983b6cd720412c7fcaaa0122f860501a06ab61ef1cc09d336"
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
