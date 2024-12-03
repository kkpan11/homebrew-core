class NodeSass < Formula
  desc "JavaScript implementation of a Sass compiler"
  homepage "https://github.com/sass/dart-sass"
  url "https://registry.npmjs.org/sass/-/sass-1.81.1.tgz"
  sha256 "e6d47862d59ab13d9c905e9209b547a2ddc3a27ba3948882bf94014915572da9"
  license "MIT"

  bottle do
    sha256                               arm64_sequoia: "88ce2938a10fb4d34d3e8050b8e99f71dbc344407f2fe69b0e55a38dd7248833"
    sha256                               arm64_sonoma:  "807739ccab11c97b1dc40c412d42b24e0b2fb3d82622ab28fc82c1a1fd5a6323"
    sha256                               arm64_ventura: "ad5fb8af60f3e142c846f8461b274cc17dc0de186cb1aee70a9372de9c9a76d3"
    sha256                               sonoma:        "1b6eb3375348137717f6bbe1168daee2ec893a80a3c4aeb0512f335f52a80eed"
    sha256                               ventura:       "9019019b7c81539626a3345858a8c17eac46dac9422cc6f173820360232d0c49"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "68b782c10d7b20c1c3dd1f0e1415b113a29ac132245edcde5a711fe4134a9342"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.scss").write <<~EOS
      div {
        img {
          border: 0px;
        }
      }
    EOS

    assert_equal "div img{border:0px}",
    shell_output("#{bin}/sass --style=compressed test.scss").strip
  end
end
