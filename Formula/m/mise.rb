class Mise < Formula
  desc "Polyglot runtime manager (asdf rust clone)"
  homepage "https://mise.jdx.dev/"
  url "https://github.com/jdx/mise/archive/refs/tags/v2024.12.7.tar.gz"
  sha256 "f958c800f5919b614d9fbb1a6dd8a4a38158d64b7cd142d0887e718c41a45b28"
  license "MIT"
  head "https://github.com/jdx/mise.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "197d7fcf99335ebf02bdd72d4de6470cdde13e4e5550de96141ae6e1e1eee178"
    sha256 cellar: :any,                 arm64_sonoma:  "96c2f807a2228b79db82cc84e6cb758606c04e731ccc49ca29ef8df3dab503bb"
    sha256 cellar: :any,                 arm64_ventura: "e21ba3cfb6a8fbffd7b284b1c7549cb346c6c0a83a6a3d6837a7c466fdb7f686"
    sha256 cellar: :any,                 sonoma:        "3f73e6695adca67e08395c3e96a7fef8f0a8c08eb83ad693bf555eba4332c968"
    sha256 cellar: :any,                 ventura:       "bf746a3363a95d8ce23c0648ff2e73f728aedebda35d7c8b691905b4a99c8b42"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5a884b882c28954c3509c74591839f901c0b7d44b315e8beac2d016983fd0d84"
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
    (share/"fish"/"vendor_conf.d"/"mise-activate.fish").write <<~FISH
      if [ "$MISE_FISH_AUTO_ACTIVATE" != "0" ]
        #{opt_bin}/mise activate fish | source
      end
    FISH
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
    system bin/"mise", "use", "go@1.23"
    assert_match "1.23", shell_output("#{bin}/mise exec -- go version")

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
