class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-39.47.0.tgz"
  sha256 "f08de53477feaad57b908192b5ac35c48c8af20c2319e339de5b46c258ed231d"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "320880884a220550c2f2160dfc4f3e774c19eb76b42c26cb1282bf341c2ff6e0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2c507315f1412671912c668fc738ad6a6cb084b18f3e15ba92e4802cd6067337"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7ffcedd87d1614d3f86ab15b868a4a140a6a67c3683d1c1b26a3ee4a1652d9f0"
    sha256 cellar: :any_skip_relocation, sonoma:        "0c3518c0653738257ed0707488995bef48d7a94132bd48028c99216812bb5d81"
    sha256 cellar: :any_skip_relocation, ventura:       "43a7fad6bf8f9833430e6711c6c5ee6db42dabaa37ea37e8428961b6af4462c5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4bbe8da64aa1287f2e79abeb15badfeb62344163cf6e78aba48e774e59b3606b"
  end

  depends_on "node@20"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
