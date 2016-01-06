class VowpalWabbit < Formula
  desc "Online learning algorithm"
  homepage "https://github.com/JohnLangford/vowpal_wabbit"
  url "https://github.com/JohnLangford/vowpal_wabbit/archive/8.0.tar.gz"
  sha256 "ebf7fea91eead6da3d9fd479b901a320d5ab3ed20b2b134b5ce86aec771b0a60"
  head "https://github.com/JohnLangford/vowpal_wabbit.git"
  revision 1

  bottle do
    cellar :any
    sha256 "158cb297f18c9ace81658cf29218b830f7ff861692f1cea2ff8d77bcf3957d42" => :el_capitan
    sha256 "f80d7f6b1a2fc2178110132e733d27b5dec66b79d6664b830dee6e89114874f1" => :yosemite
    sha256 "2c07a0f02f3b7f7c1af5b6a1aefd5a1edb0098d9f2437218f638bb967c527901" => :mavericks
  end

  if MacOS.version < :mavericks
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  needs :cxx11

  def install
    ENV.cxx11
    ENV["AC_PATH"] = "#{HOMEBREW_PREFIX}/share"
    system "./autogen.sh", "--prefix=#{prefix}",
                           "--with-boost=#{Formula["boost"].opt_prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"house_dataset").write <<-EOS.undent
      0 | price:.23 sqft:.25 age:.05 2006
      1 2 'second_house | price:.18 sqft:.15 age:.35 1976
      0 1 0.5 'third_house | price:.53 sqft:.32 age:.87 1924
    EOS
    system bin/"vw", "house_dataset", "-l", "10", "-c", "--passes", "25", "--holdout_off", "--audit", "-f", "house.model", "--nn", "5"
    system bin/"vw", "-t", "-i", "house.model", "-d", "house_dataset", "-p", "house.predict"

    (testpath/"csoaa.dat").write <<-EOS.undent
      1:1.0 a1_expect_1| a
      2:1.0 b1_expect_2| b
      3:1.0 c1_expect_3| c
      1:2.0 2:1.0 ab1_expect_2| a b
      2:1.0 3:3.0 bc1_expect_2| b c
      1:3.0 3:1.0 ac1_expect_3| a c
      2:3.0 d1_expect_2| d
    EOS
    system bin/"vw", "--csoaa", "3", "csoaa.dat", "-f", "csoaa.model"
    system bin/"vw", "-t", "-i", "csoaa.model", "-d", "csoaa.dat", "-p", "csoaa.predict"

    (testpath/"ect.dat").write <<-EOS.undent
      1 ex1| a
      2 ex2| a b
      3 ex3| c d e
      2 ex4| b a
      1 ex5| f g
    EOS
    system bin/"vw", "--ect", "3", "-d", "ect.dat", "-f", "ect.model"
    system bin/"vw", "-t", "-i", "ect.model", "-d", "ect.dat", "-p", "ect.predict"

    (testpath/"train.dat").write <<-EOS.undent
    1:2:0.4 | a c
      3:0.5:0.2 | b d
      4:1.2:0.5 | a b c
      2:1:0.3 | b c
      3:1.5:0.7 | a d
    EOS
    (testpath/"test.dat").write <<-EOS.undent
      1:2 3:5 4:1:0.6 | a c d
      1:0.5 2:1:0.4 3:2 4:1.5 | c d
    EOS
    system bin/"vw", "-d", "train.dat", "--cb", "4", "-f", "cb.model"
    system bin/"vw", "-t", "-i", "cb.model", "-d", "test.dat", "-p", "cb.predict"
  end
end
