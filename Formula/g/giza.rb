class Giza < Formula
  desc "Scientific plotting library for C/Fortran built on cairo"
  homepage "https://danieljprice.github.io/giza/"
  url "https://github.com/danieljprice/giza/archive/refs/tags/v1.4.2.tar.gz"
  sha256 "4045ebb35b2fc382f045de7c51f84515c22d1aa534fd13d0fc9efea7e5303793"
  license "LGPL-3.0-only"
  head "https://github.com/danieljprice/giza.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "cb433ba5a7500b66955e473a9681d2fcdf8cc9d6d93d40a3722110c80c5ab404"
    sha256 cellar: :any,                 arm64_sonoma:  "ade3a30cb4a4765788f68479617f2484d35fb0caa078193a00f0b99477ec28cc"
    sha256 cellar: :any,                 arm64_ventura: "3dcc3b0388e99317e3c028699415235f45837ec2d11f64c4fb8484c47fb6bd40"
    sha256 cellar: :any,                 sonoma:        "f3066b84cefaad4d9c44431ceade7c450650521019e0a4ec6483a57f833749ad"
    sha256 cellar: :any,                 ventura:       "7c789190c40e7565da9b6aeb9c736751907567185c05d1709764dc17a76dac55"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2bb290e8cf63f664cfda366241aec7c0e8d25e32d046caabb9a48bde28617a5b"
  end

  depends_on "pkgconf" => :build

  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "libx11"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"

    # Clean up stray Makefiles in test folder
    makefiles = File.join("test", "**", "Makefile*")
    Dir.glob(makefiles).each do |file|
      rm file
    end

    prefix.install "test"
  end

  def caveats
    <<~EOS
      Test suite has been installed at:
        #{opt_prefix}/test
    EOS
  end

  test do
    test_dir = "#{prefix}/test/C"
    cp_r test_dir, testpath

    flags = %W[
      -I#{include}
      -I#{Formula["cairo"].opt_include}/cairo
      -L#{lib}
      -L#{Formula["libx11"].opt_lib}
      -L#{Formula["cairo"].opt_lib}
      -lX11
      -lcairo
      -lgiza
    ]

    %w[
      test-XOpenDisplay.c
      test-cairo-xw.c
      test-giza-xw.c
      test-rectangle.c
      test-window.c
    ].each do |file|
      system ENV.cc, testpath/"C"/file, *flags
    end
  end
end
