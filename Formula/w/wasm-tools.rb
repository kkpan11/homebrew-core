class WasmTools < Formula
  desc "Low level tooling for WebAssembly in Rust"
  homepage "https://github.com/bytecodealliance/wasm-tools"
  url "https://github.com/bytecodealliance/wasm-tools/archive/refs/tags/v1.221.1.tar.gz"
  sha256 "011cff93aea17fa6d0663ad4767a4f979a64e7d03fa538cf6c3c3a8ba6296956"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/bytecodealliance/wasm-tools.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "43224a86817b1124c1411e56fdb40b4b57cde3c21462d183f68816f13ee35e91"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d8a828b5fcd2a3b3c192203660862244aa86256b44aa6569e1c9c33b08a789eb"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "868ae930d5fdfec9cc14fbb4986f7c8faa907331452b359b8651e834ee0a292c"
    sha256 cellar: :any_skip_relocation, sonoma:        "6227d011e14409b3eb8d49ec7b3e0bfae39d5188d46088b328badc429247c0b8"
    sha256 cellar: :any_skip_relocation, ventura:       "49f0ed21d6022e256348a8dd8e49942bbb084236273f00bfc259b9f5d03dca70"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "395310e7a9602b2d5a5f1abed1623fceb0a5b0268dc5586d1a0077688bbc7472"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    wasm = ["0061736d0100000001070160027f7f017f030201000707010373756d00000a09010700200020016a0b"].pack("H*")
    (testpath/"sum.wasm").write(wasm)
    system bin/"wasm-tools", "validate", testpath/"sum.wasm"

    expected = <<~EOS
      (module
        (type (;0;) (func (param i32 i32) (result i32)))
        (export "sum" (func 0))
        (func (;0;) (type 0) (param i32 i32) (result i32)
          local.get 0
          local.get 1
          i32.add
        )
      )
    EOS
    assert_equal expected, shell_output("#{bin}/wasm-tools print #{testpath}/sum.wasm")
  end
end
