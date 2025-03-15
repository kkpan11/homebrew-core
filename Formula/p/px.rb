class Px < Formula
  include Language::Python::Virtualenv

  desc "Ps and top for human beings (px / ptop)"
  homepage "https://github.com/walles/px"
  url "https://github.com/walles/px.git",
      tag:      "3.6.6",
      revision: "08d821f933aa3ea6a605c9ed73e6e75c096c1b32"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "830a84b3f11a0bb84601ed256a9ec5d7ab67ea61fd2c444736d89e0edda1f836"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "830a84b3f11a0bb84601ed256a9ec5d7ab67ea61fd2c444736d89e0edda1f836"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "830a84b3f11a0bb84601ed256a9ec5d7ab67ea61fd2c444736d89e0edda1f836"
    sha256 cellar: :any_skip_relocation, sonoma:        "8e8729173b0fae0666ee1eacc8921a977512765306dfe7f0ce3dff3025c0a4db"
    sha256 cellar: :any_skip_relocation, ventura:       "8e8729173b0fae0666ee1eacc8921a977512765306dfe7f0ce3dff3025c0a4db"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "830a84b3f11a0bb84601ed256a9ec5d7ab67ea61fd2c444736d89e0edda1f836"
  end

  depends_on "python@3.13"

  uses_from_macos "lsof"

  conflicts_with "fpc", because: "both install `ptop` binaries"
  conflicts_with "pixie", because: "both install `px` binaries"

  def install
    system "python3", "devbin/update_version_py.py"

    virtualenv_install_with_resources

    man1.install Dir["doc/*.1"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/px --version")

    split_first_line = pipe_output("#{bin}/px --no-pager").lines.first.split
    assert_equal %w[PID COMMAND USERNAME CPU CPUTIME RAM COMMANDLINE], split_first_line
  end
end
