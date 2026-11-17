class AwsEmulator < Formula
  desc "Local emulator of the AWS APIs"
  homepage "https://github.com/aws/aws-emulator"
  url "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator_1.0.490-1_amd64.deb"
  version "1.0.490"
  sha256 "3b9a6f9a1e1e4543c76d033f669af7687953eff108e4ec8982d9af91189561e9"
  license all_of: ["CC0-1.0", "Apache-2.0"]

  livecheck do
    url "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/versions.json"
    strategy :json do |json|
      json["versions"]&.map { |item| item["version"]&.sub(/\.\d+$/, "") }
    end
  end

  on_macos do
    depends_on arch: :arm64

    # Upstream ships Linux packages only. This tap builds macOS arm64 from the upstream tag
    # with macos/aws-emulator-run-memory.patch (see macos/build-aws-emulator.sh).
    on_arm do
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/aws-emulator-1.0.490/aws-emulator-1.0.490-macos-arm64.tar.gz"
      sha256 "a5619ea05f288650cb6379bc2e76a9d2750552216638c372b89c867727cefb5b"
    end
  end

  on_linux do
    depends_on "xz" => :build

    on_arm do
      url "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator_1.0.490-1_arm64.deb"
      sha256 "844c0ea1810bb627d0abcdd57375b4dd03fc8ad64a3da9df2cc138b4c85f58b4"
    end
  end

  def install
    if OS.mac?
      libexec.install "aws-emulator"
      prefix.install "THIRD_PARTY_LICENSES"
    else
      system "ar", "x", cached_download
      system "tar", "xf", "data.tar.xz"
      libexec.install "opt/aws-emulator/bin/aws-emulator"
      prefix.install "opt/aws-emulator/THIRD_PARTY_LICENSES"
    end
    bin.install_symlink libexec/"aws-emulator"
  end

  test do
    ENV["EMULATOR_TELEMETRY"] = "off"
    assert_match version.to_s, shell_output("#{bin}/aws-emulator --version")

    port = free_port
    pid = spawn bin/"aws-emulator", "--port", port.to_s, "--telemetry", "off", "--idle-timeout", "60"
    begin
      ca = testpath/".aws/emulator/#{port}/ca.pem"
      30.times do
        break if ca.exist?

        sleep 1
      end
      output = shell_output("curl -fsS --retry 5 --retry-connrefused --cacert #{ca} " \
                            "https://127.0.0.1:#{port}/__admin/health")
      assert_match "ok", output
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
