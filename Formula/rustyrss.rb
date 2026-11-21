class Rustyrss < Formula
  desc "Self-hosted RSS server with REST, WebSocket and MCP, plus a terminal reader"
  homepage "https://github.com/jeffabailey/homebrew-tap"
  version "0.1.0"
  license "Apache-2.0"

  # The source repository is private. This tap publishes the binaries as
  # releases of its own, built from rustyrss commit 3c36f84.
  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.0/rustyrss-0.1.0-macos-arm64.tar.gz"
      sha256 "99c50e2559961e66cd5c225f4e850dd99d35a9fe0666b06c55db104f7039b87d"
    end
  end

  on_linux do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/rustyrss-0.1.0/rustyrss-0.1.0-linux-arm64.tar.gz"
      sha256 "eb74414ef5954ac61617d183e46b1676415cd7a1254ab375036f56206559cc5a"
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
