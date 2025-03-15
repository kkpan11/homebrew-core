class Goreleaser < Formula
  desc "Deliver Go binaries as fast and easily as possible"
  homepage "https://goreleaser.com/"
  url "https://github.com/goreleaser/goreleaser.git",
      tag:      "v2.8.1",
      revision: "bb4ba3820ee89a94eb2051cb9de86417addd08ba"
  license "MIT"
  head "https://github.com/goreleaser/goreleaser.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "78df45b2d3f558d67808d86789e8bc2de21c6800d219a3f39bcd44f24515aaf5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "78df45b2d3f558d67808d86789e8bc2de21c6800d219a3f39bcd44f24515aaf5"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "78df45b2d3f558d67808d86789e8bc2de21c6800d219a3f39bcd44f24515aaf5"
    sha256 cellar: :any_skip_relocation, sonoma:        "0b3bb9173bb8155d0a6f13fbaed4c81110de8e0f87be53eaa7bbd444837bb5eb"
    sha256 cellar: :any_skip_relocation, ventura:       "0b3bb9173bb8155d0a6f13fbaed4c81110de8e0f87be53eaa7bbd444837bb5eb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d43915658d680aa74a6d49f08bf93a7d731315af05a53debe390e730a4a8a5ea"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.commit=#{Utils.git_head}
      -X main.builtBy=homebrew
    ]

    system "go", "build", *std_go_args(ldflags:)

    # Install shell completions
    generate_completions_from_executable(bin/"goreleaser", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goreleaser -v 2>&1")
    assert_match "thanks for using GoReleaser!", shell_output("#{bin}/goreleaser init --config=.goreleaser.yml 2>&1")
    assert_path_exists testpath/".goreleaser.yml"
  end
end
