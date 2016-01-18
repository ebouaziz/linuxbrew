class Pod2man < Formula
  desc "perl documentation generator"
  homepage "http://www.eyrie.org/~eagle/software/podlators/"
  url "http://archives.eyrie.org/software/perl/podlators-4.05.tar.xz"
  sha256 "2eb8ef07720ad2f06451c1a1215c4777423c5c22ab7d05643f0155e344fd554c"

  bottle do
    cellar :any_skip_relocation
    sha256 "231ffab06e0aabb25b3630e4e2ba1990dc32abb3b7a3336c6880db4a0f721928" => :el_capitan
    sha256 "58004f85a51625bfc5d3666d4a082268d5a280d76bc0da6a37f3b9991ba3b610" => :yosemite
    sha256 "e47670d56d9a8bf9a5822c21fb35f9e663bcfd596fcda91f4a595cdcc53697eb" => :mavericks
  end

  keg_only :provided_by_osx

  def install
    system "perl", "Makefile.PL", "PREFIX=#{prefix}",
                   "INSTALLSCRIPT=#{bin}",
                   "INSTALLMAN1DIR=#{man1}", "INSTALLMAN3DIR=#{man3}"
    system "make", "install"
  end

  test do
    (testpath/"test.pod").write "=head2 Test heading\n"
    manpage = shell_output("#{bin}/pod2man #{testpath}/test.pod")
    assert_match '.SS "Test heading"', manpage
  end
end
