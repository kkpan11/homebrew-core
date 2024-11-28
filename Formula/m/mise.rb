class Mise < Formula
  desc "Polyglot runtime manager (asdf rust clone)"
  homepage "https://mise.jdx.dev/"
  url "https://github.com/jdx/mise/archive/refs/tags/v2024.11.31.tar.gz"
  sha256 "dd044d96da27578b2b960d4a14626d7ad3f284fe16d826f7bb1a8192fb7ebd37"
  license "MIT"
  head "https://github.com/jdx/mise.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "d8dc8a28ddfe999fa99bb2df01ed0bb7ffc8ffdab62736cff27e52f7db54a4aa"
    sha256 cellar: :any,                 arm64_sonoma:  "0d59f06a009b0e465d64bc7ddf557df310c15b007f9ef5a176ed4cf03c8f3d5b"
    sha256 cellar: :any,                 arm64_ventura: "2f269e6c36727d6f59fb6d59766edfbc99284a87888af698ca37aabe9b3cd006"
    sha256 cellar: :any,                 sonoma:        "0feb5138d1ea0bb2519d8afb86d295c0c1f2c51e3d84faa9c0eb7a01aeec5572"
    sha256 cellar: :any,                 ventura:       "3c5418cafb735b177096e3f82004b8d1a3f4522fa14d8f9ffa373b927760dfbb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "de4853df57bba91aaa39cabc90b8059f28a00860c99c87d5d13652ddd9f6103d"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  depends_on "libgit2"
  depends_on "openssl@3"
  depends_on "usage"

  uses_from_macos "bzip2"

  on_linux do
    depends_on "xz" # for liblzma
  end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    system "cargo", "install", *std_cargo_args
    man1.install "man/man1/mise.1"
    generate_completions_from_executable(bin/"mise", "completion")
    lib.mkpath
    touch lib/".disable-self-update"
    (share/"fish"/"vendor_conf.d"/"mise-activate.fish").write <<~EOS
      if [ "$MISE_FISH_AUTO_ACTIVATE" != "0" ]
        #{opt_bin}/mise activate fish | source
      end
    EOS
  end

  def caveats
    <<~EOS
      If you are using fish shell, mise will be activated for you automatically.
    EOS
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    system bin/"mise", "settings", "set", "experimental", "true"
    system bin/"mise", "use", "node@22"
    assert_match "22", shell_output("#{bin}/mise exec -- node -v")

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"mise", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
