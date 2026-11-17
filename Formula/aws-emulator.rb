class AwsEmulator < Formula
  desc "Local emulator of the AWS APIs"
  homepage "https://github.com/aws/aws-emulator"
  url "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator_1.0.481-1_amd64.deb"
  version "1.0.481"
  sha256 "fd8f96b1d51384c405f8d545ad2b8ece06d398acafdbf4ad7cfbe27a595d8e19"
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
      url "https://github.com/jeffabailey/homebrew-tap/releases/download/aws-emulator-1.0.481/aws-emulator-1.0.481-macos-arm64.tar.gz"
      sha256 "62a185a2b80248650f31a11aa8ede4ac2c55f41dfbe2d45146e2473b30a2dcfc"
    end
  end

  on_linux do
    depends_on "xz" => :build

    on_arm do
      url "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator_1.0.481-1_arm64.deb"
      sha256 "5678945846c5db9444d682a9e28fdc57616224702d7678f36ca020c4495131ac"
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
