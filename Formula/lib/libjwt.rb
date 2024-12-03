class Libjwt < Formula
  desc "JSON Web Token C library"
  homepage "https://github.com/benmcollins/libjwt"
  url "https://github.com/benmcollins/libjwt/releases/download/v1.18.2/libjwt-1.18.2.tar.bz2"
  sha256 "6b10af67157c65b201ba881d040408d2450c0a152b4e7547cc3ec1952cd75b63"
  license "MPL-2.0"
  head "https://github.com/benmcollins/libjwt.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "8be26cae4c691069802bb2239781bff751eda588a2dea7d2237fd8a66824ac0a"
    sha256 cellar: :any,                 arm64_sonoma:  "f2e0b6657d2340ca76bc6993192db6a73bc954f3b6f8c3ba73324181aebb51b2"
    sha256 cellar: :any,                 arm64_ventura: "2f272168a2207d81184718b1ded6587f543fd37aa7d3dae94a3969f66d010a53"
    sha256 cellar: :any,                 sonoma:        "ab0981e7e73c09a5c33fe14bcec0814b150561a62e8c471c6fa93256ef81e96d"
    sha256 cellar: :any,                 ventura:       "e8d5b3735e1ba301e9246d31cb723eec9204a7911a96200bea216a980954ebf9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a9bdc84f671f069561c6c5d7f918b60d0968ae812e50ce1dcdfa1df59f1caa43"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "jansson"
  depends_on "openssl@3"

  def install
    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdlib.h>
      #include <jwt.h>

      int main() {
        jwt_t *jwt = NULL;
        if (jwt_new(&jwt) != 0) return 1;
        return 0;
      }
    C
    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}", "-ljwt", "-o", "test"
    system "./test"
  end
end
