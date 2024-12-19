class Mdz < Formula
  desc "CLI for the mdz ledger Open Source"
  homepage "https://github.com/LerianStudio/midaz"
  url "https://github.com/LerianStudio/midaz/archive/refs/tags/v1.35.0.tar.gz"
  sha256 "bf34611a40954df81f314bde8ae8d5b05c0841539aa028096fabe65f4cb359df"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fee9d087e89a2b16ddce2722d0fb9daf5c2c2ef8a81d58673de0a1b4b9fdff7c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fee9d087e89a2b16ddce2722d0fb9daf5c2c2ef8a81d58673de0a1b4b9fdff7c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "fee9d087e89a2b16ddce2722d0fb9daf5c2c2ef8a81d58673de0a1b4b9fdff7c"
    sha256 cellar: :any_skip_relocation, sonoma:        "c86c95640fb95307fc9a01a851197edf8722095c9eb190791a11488cec5502b3"
    sha256 cellar: :any_skip_relocation, ventura:       "c86c95640fb95307fc9a01a851197edf8722095c9eb190791a11488cec5502b3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "65ea4029f70334e02be4fbe3f9c21ecc0641f1fe5b2b991603e8d29e2b2e5402"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/LerianStudio/midaz/components/mdz/pkg/environment.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./components/mdz"
  end

  test do
    assert_match "Mdz CLI #{version}", shell_output("#{bin}/mdz --version")

    client_id = "9670e0ca55a29a466d31"
    client_secret = "dd03f916cacf4a98c6a413d9c38ba102dce436a9"
    url_api_auth = "http://127.0.0.1:8080"
    url_api_ledger = "http://127.0.0.1:3000"

    output = shell_output("#{bin}/mdz configure --client-id #{client_id} " \
                          "--client-secret #{client_secret} --url-api-auth #{url_api_auth} " \
                          "--url-api-ledger #{url_api_ledger}")

    assert_match "client-id:       9670e0ca55a29a466d31", output
    assert_match "client-secret:   dd03f916cacf4a98c6a413d9c38ba102dce436a9", output
    assert_match "url-api-auth:    http://127.0.0.1:8080", output
    assert_match "url-api-ledger:  http://127.0.0.1:3000", output
  end
end
