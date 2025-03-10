class AdaUrl < Formula
  desc "WHATWG-compliant and fast URL parser written in modern C++"
  homepage "https://github.com/ada-url/ada"
  url "https://github.com/ada-url/ada/archive/refs/tags/v3.2.0.tar.gz"
  sha256 "49935314401b78f728f9d9bcc2e4a38905f62d4987621a2b318d251e3a04acf3"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/ada-url/ada.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "30b3650ff80c9a8a8245b986b2cd0cffe3127102d420214d7d99cd41c0149c2a"
    sha256 cellar: :any,                 arm64_sonoma:  "e99fb8674f4532d20b91a1c9a242bece2c8da9fd86f4990a7e1115b3fe6137fd"
    sha256 cellar: :any,                 arm64_ventura: "5774a1c1fbfdf50a478b24fcf97258251f60f4fca0b3ec7e70fcaffea8d3ddcf"
    sha256 cellar: :any,                 sonoma:        "4da908e0d4a9d26c8a5776d9f39f439c36256b5e7c5e37f5874185d7676639d6"
    sha256 cellar: :any,                 ventura:       "c7df375bbd01b21c2b764bcef8dad522f984efb73d9c5e346c64ffb72781207f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9251875d60535fdf8230b995a18a6a5f7d1eb5b524bcd0372bbc8437ca004100"
  end

  depends_on "cmake" => :build

  uses_from_macos "python" => :build

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1500
  end

  fails_with :clang do
    build 1500
    cause "Requires C++20 support"
  end

  fails_with :gcc do
    version "11"
    cause "Requires C++20"
  end

  def install
    ENV.llvm_clang if OS.mac? && DevelopmentTools.clang_build_version <= 1500

    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    ENV["CXX"] = Formula["llvm"].opt_bin/"clang++" if OS.mac? && DevelopmentTools.clang_build_version <= 1500

    (testpath/"test.cpp").write <<~CPP
      #include "ada.h"
      #include <iostream>

      int main(int , char *[]) {
        auto url = ada::parse<ada::url_aggregator>("https://www.github.com/ada-url/ada");
        url->set_protocol("http");
        std::cout << url->get_protocol() << std::endl;
        return EXIT_SUCCESS;
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++20",
           "-I#{include}", "-L#{lib}", "-lada", "-o", "test"
    assert_equal "http:", shell_output("./test").chomp
  end
end
