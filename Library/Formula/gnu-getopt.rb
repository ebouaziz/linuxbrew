class GnuGetopt < Formula
  desc "Command-line option parsing library"
  homepage "http://software.frodo.looijaard.name/getopt/"
  url "http://frodo.looijaard.name/system/files/software/getopt/getopt-1.1.6.tar.gz"
  sha1 "98725b4878d19ab6b126cd16263fed1f6090f6a7"

  bottle do
    sha1 "a9028999ae9bb3e606df3ff6a1b246311b77fae5" => :yosemite
    sha1 "6e8df00f7607127df705d7c1eb6a046e599f7825" => :mavericks
    sha1 "cbd65e8f5e2c613d48dfefdcb801aa0a7ecdc10f" => :mountain_lion
  end

  depends_on "gettext"

  keg_only :provided_by_osx

  def install
    inreplace "Makefile" do |s|
      gettext = Formula["gettext"]
      s.change_make_var! "CPPFLAGS", "\\1 -I#{gettext.include}"
      s.change_make_var! "LDFLAGS", "\\1 -L#{gettext.lib} -lintl"
    end if OS.mac?
    system "make", "prefix=#{prefix}", "mandir=#{man}", "install"
  end

  test do
    system "#{bin}/getopt", "-o", "--test"
  end
end
