class Doc8 < Formula
  include Language::Python::Virtualenv

  desc "Style checker for Sphinx documentation"
  homepage "https://github.com/PyCQA/doc8"
  url "https://files.pythonhosted.org/packages/11/28/b0a576233730b756ca1ebb422bc6199a761b826b86e93e5196dfa85331ea/doc8-1.1.2.tar.gz"
  sha256 "1225f30144e1cc97e388dbaf7fe3e996d2897473a53a6dae268ddde21c354b98"
  license "Apache-2.0"
  head "https://github.com/PyCQA/doc8.git", branch: "main"

  bottle do
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "19afe5fe6d519aa6f95b9bfcdc03217d80e1eef12845f1cf4a6df6666dd13be0"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "34c2af1d4bcaceda69f99623f6477f10338e6c7bfae75e4747a761d4e27d9c01"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f243afe79d6c21dc8bdec9cb3dec2fe28844b7f9dd7540f2d361b98e4603f3af"
    sha256 cellar: :any_skip_relocation, sonoma:         "97589fd0e5a9ff1e28462a7f57dbb74cadbc8f50fa665972c7dac7e6a70ea2fa"
    sha256 cellar: :any_skip_relocation, ventura:        "fa252efb596300267b70559c70d5f9ee051303ddb8d1f96e36d6491b6ffeeb97"
    sha256 cellar: :any_skip_relocation, monterey:       "b87a1b15782d7290d386fae72081a3b2f1629cb276aa5292710940c31b794ef8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0be4c5cee6cd61e606a920a4803c9dbe4ca30c65b340679408d5f579a4219f29"
  end

  depends_on "python@3.12"

  resource "docutils" do
    url "https://files.pythonhosted.org/packages/ae/ed/aefcc8cd0ba62a0560c3c18c33925362d46c6075480bfa4df87b28e169a9/docutils-0.21.2.tar.gz"
    sha256 "3a6b18732edf182daa3cd12775bbb338cf5691468f91eeeb109deff6ebfa986f"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/b2/35/80cf8f6a4f34017a7fe28242dc45161a1baa55c41563c354d8147e8358b2/pbr-6.1.0.tar.gz"
    sha256 "788183e382e3d1d7707db08978239965e8b9e4e5ed42669bf4758186734d5f24"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/8e/62/8336eff65bcbc8e4cb5d05b55faf041285951b6e80f33e2bff2024788f31/pygments-2.18.0.tar.gz"
    sha256 "786ff802f32e91311bff3889f6e9a86e81505fe99f2735bb6d60ae0c5004f199"
  end

  resource "restructuredtext-lint" do
    url "https://files.pythonhosted.org/packages/48/9c/6d8035cafa2d2d314f34e6cd9313a299de095b26e96f1c7312878f988eec/restructuredtext_lint-1.4.0.tar.gz"
    sha256 "1b235c0c922341ab6c530390892eb9e92f90b9b75046063e047cacfb0f050c45"
  end

  resource "stevedore" do
    url "https://files.pythonhosted.org/packages/c4/59/f8aefa21020054f553bf7e3b405caec7f8d1f432d9cb47e34aaa244d8d03/stevedore-5.3.0.tar.gz"
    sha256 "9a64265f4060312828151c204efbe9b7a9852a0d9228756344dbc7e4023e375a"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"broken.rst").write <<~EOS
      Heading
      ------
    EOS
    output = pipe_output("#{bin}/doc8 broken.rst 2>&1")
    assert_match "D000 Title underline too short.", output
  end
end
