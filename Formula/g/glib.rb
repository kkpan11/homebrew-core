class Glib < Formula
  include Language::Python::Shebang

  desc "Core application library for C"
  homepage "https://docs.gtk.org/glib/"
  url "https://download.gnome.org/sources/glib/2.82/glib-2.82.5.tar.xz"
  sha256 "05c2031f9bdf6b5aba7a06ca84f0b4aced28b19bf1b50c6ab25cc675277cbc3f"
  license "LGPL-2.1-or-later"

  bottle do
    sha256 arm64_sequoia: "1cb81bf4e51c9d5f2076bd25f048d54e3dfef275a56181ae556d0f00202134f9"
    sha256 arm64_sonoma:  "0f59834321c70454c8287133ae3b6d299e5555fd1e90168ef800b8583e85f02c"
    sha256 arm64_ventura: "76c6ad473c539a960692819801a130d4b943d3228c45dfb5738ba6bdde2433d8"
    sha256 sonoma:        "1617041c672d28d0689cfb148bea039d99ce5672e785ac668b05899de3cae025"
    sha256 ventura:       "1f7cf7df88c97edde8ed504caa2fbf4930bd72306a639c7c75c79e628f9ecea6"
    sha256 x86_64_linux:  "0db74b4ee32118ea223445f654487ca4b1349535e35be07b98d486cae80e1ebd"
  end

  depends_on "bison" => :build # for gobject-introspection
  depends_on "gettext" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "pcre2"

  uses_from_macos "flex" => :build # for gobject-introspection
  uses_from_macos "libffi", since: :catalina
  uses_from_macos "python", since: :catalina
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
  end

  on_system :linux, macos: :mojave_or_older do
    depends_on "python-setuptools" => :build # for gobject-introspection
  end

  on_linux do
    depends_on "dbus"
    depends_on "util-linux"
  end

  # These used to live in the now defunct `glib-utils`.
  link_overwrite "bin/gdbus-codegen", "bin/glib-genmarshal", "bin/glib-mkenums", "bin/gtester-report"
  link_overwrite "share/glib-2.0/codegen", "share/glib-2.0/gdb"
  # These used to live in `gobject-introspection`
  link_overwrite "lib/girepository-1.0/GLib-2.0.typelib", "lib/girepository-1.0/GModule-2.0.typelib",
                 "lib/girepository-1.0/GObject-2.0.typelib", "lib/girepository-1.0/Gio-2.0.typelib"
  link_overwrite "share/gir-1.0/GLib-2.0.gir", "share/gir-1.0/GModule-2.0.gir",
                 "share/gir-1.0/GObject-2.0.gir", "share/gir-1.0/Gio-2.0.gir"

  resource "gobject-introspection" do
    url "https://download.gnome.org/sources/gobject-introspection/1.82/gobject-introspection-1.82.0.tar.xz"
    sha256 "0f5a4c1908424bf26bc41e9361168c363685080fbdb87a196c891c8401ca2f09"
  end

  # Backport PATH python shebang rather than manually rewriting
  patch do
    url "https://gitlab.gnome.org/GNOME/glib/-/commit/160e55575e2183464dbf5aa733d6c2df3c674c4c.diff"
    sha256 "29b178b53a9a636ca9538ee97e20838b9942d24018d6679d3cc29e59b3b6c0c1"
  end

  # replace several hardcoded paths with homebrew counterparts
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/b46d8deae6983110b4e39bb2971bcbd10bb59716/glib/hardcoded-paths.diff"
    sha256 "d846efd0bf62918350da94f850db33b0f8727fece9bfaf8164566e3094e80c97"
  end

  def install
    # Avoid the sandbox violation when an empty directory is created outside of the formula prefix.
    inreplace "gio/meson.build", "install_emptydir(glib_giomodulesdir)", ""

    # build patch for `ld: missing LC_LOAD_DYLIB (must link with at least libSystem.dylib) \
    # in ../gobject-introspection-1.80.1/build/tests/offsets/liboffsets-1.0.1.dylib`
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if OS.mac? && MacOS.version == :ventura

    # Disable dtrace; see https://trac.macports.org/ticket/30413
    # and https://gitlab.gnome.org/GNOME/glib/-/issues/653
    args = %W[
      --localstatedir=#{var}
      -Dgio_module_dir=#{HOMEBREW_PREFIX}/lib/gio/modules
      -Dbsymbolic_functions=false
      -Ddtrace=false
      -Druntime_dir=#{var}/run
      -Dtests=false
    ]

    # Stage build in order to deal with circular dependency as `gobject-introspection`
    # is needed to generate `glib` introspection data used by dependents; however,
    # `glib` is a dependency of `gobject-introspection`.
    # Ref: https://discourse.gnome.org/t/dealing-with-glib-and-gobject-introspection-circular-dependency/18701
    staging_dir = buildpath/"staging"
    staging_meson_args = std_meson_args.map { |s| s.sub prefix, staging_dir }
    system "meson", "setup", "build_staging", "-Dintrospection=disabled", *args, *std_meson_args
    system "meson", "compile", "-C", "build_staging", "--verbose"
    system "meson", "install", "-C", "build_staging"
    ENV.append_path "PKG_CONFIG_PATH", lib/"pkgconfig"
    ENV.append_path "LD_LIBRARY_PATH", lib if OS.linux?

    resource("gobject-introspection").stage do
      system "meson", "setup", "build", "-Dcairo=disabled", "-Ddoctool=disabled", *staging_meson_args
      system "meson", "compile", "-C", "build", "--verbose"
      system "meson", "install", "-C", "build"
    end
    ENV.append_path "PKG_CONFIG_PATH", staging_dir/"lib/pkgconfig"
    ENV.append_path "LD_LIBRARY_PATH", staging_dir/"lib" if OS.linux?
    ENV.append_path "PATH", staging_dir/"bin"

    system "meson", "setup", "build", "--default-library=both", "-Dintrospection=enabled", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    # ensure giomoduledir contains prefix, as this pkgconfig variable will be
    # used by glib-networking and glib-openssl to determine where to install
    # their modules
    inreplace lib/"pkgconfig/gio-2.0.pc",
              "giomoduledir=#{HOMEBREW_PREFIX}/lib/gio/modules",
              "giomoduledir=${libdir}/gio/modules"

    (buildpath/"gio/completion/.gitignore").unlink
    bash_completion.install (buildpath/"gio/completion").children
    return unless OS.mac?

    # `pkg-config --libs glib-2.0` includes -lintl, and gettext itself does not
    # have a pkgconfig file, so we add gettext lib and include paths here.
    gettext = Formula["gettext"]
    inreplace lib/"pkgconfig/glib-2.0.pc" do |s|
      s.gsub! "Libs: -L${libdir} -lglib-2.0 -lintl",
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext.opt_lib} -lintl"
      s.gsub! "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include",
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext.opt_include}"
    end
    return if MacOS.version >= :catalina

    # `pkg-config --print-requires-private gobject-2.0` includes libffi,
    # but that package is keg-only so it needs to look for the pkgconfig file
    # in libffi's opt path.
    inreplace lib/"pkgconfig/gobject-2.0.pc",
              "Requires.private: libffi",
              "Requires.private: #{Formula["libffi"].opt_lib}/pkgconfig/libffi.pc"
  end

  def post_install
    (HOMEBREW_PREFIX/"lib/gio/modules").mkpath
  end

  test do
    (testpath/"test.c").write <<~C
      #include <string.h>
      #include <glib.h>

      int main(void)
      {
          gchar *result_1, *result_2;
          char *str = "string";

          result_1 = g_convert(str, strlen(str), "ASCII", "UTF-8", NULL, NULL, NULL);
          result_2 = g_convert(result_1, strlen(result_1), "UTF-8", "ASCII", NULL, NULL, NULL);

          return (strcmp(str, result_2) == 0) ? 0 : 1;
      }
    C
    system ENV.cc, "-o", "test", "test.c", "-I#{include}/glib-2.0",
                   "-I#{lib}/glib-2.0/include", "-L#{lib}", "-lglib-2.0"
    system "./test"

    assert_match "This file is generated by glib-mkenum", shell_output(bin/"glib-mkenums")

    (testpath/"net.Corp.MyApp.Frobber.xml").write <<~XML
      <node>
        <interface name="net.Corp.MyApp.Frobber">
          <method name="HelloWorld">
            <arg name="greeting" direction="in" type="s"/>
            <arg name="response" direction="out" type="s"/>
          </method>

          <signal name="Notification">
            <arg name="icon_blob" type="ay"/>
            <arg name="height" type="i"/>
            <arg name="messages" type="as"/>
          </signal>

          <property name="Verbose" type="b" access="readwrite"/>
        </interface>
      </node>
    XML

    system bin/"gdbus-codegen", "--generate-c-code", "myapp-generated",
                                "--c-namespace", "MyApp",
                                "--interface-prefix", "net.corp.MyApp.",
                                "net.Corp.MyApp.Frobber.xml"
    assert_path_exists testpath/"myapp-generated.c"
    assert_match "my_app_net_corp_my_app_frobber_call_hello_world", (testpath/"myapp-generated.h").read

    # Keep (u)int64_t and g(u)int64 aligned. See install comment for details
    (testpath/"typecheck.cpp").write <<~CPP
      #include <cstdint>
      #include <type_traits>
      #include <glib.h>

      int main()
      {
        static_assert(std::is_same<int64_t, gint64>::value == true, "gint64 should match int64_t");
        static_assert(std::is_same<uint64_t, guint64>::value == true, "guint64 should match uint64_t");
        return 0;
      }
    CPP
    system ENV.cxx, "-o", "typecheck", "typecheck.cpp", "-I#{include}/glib-2.0", "-I#{lib}/glib-2.0/include"
  end
end
