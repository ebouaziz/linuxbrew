class Ghc < Formula
  desc "Glorious Glasgow Haskell Compilation System"
  homepage "https://haskell.org/ghc/"
  url "https://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-src.tar.xz"
  sha256 "54cd73755b784d78e2f13d5eb161bfa38d3efee9e8a56f7eb6cd9f2d6e2615f5"

  bottle do
    revision 1
    sha256 "1ce1a67a1bf09dabf97f105a536b1ab0a0b59b3bfd1e9cdd288aaae500bc79c3" => :el_capitan
    sha256 "cc097abdfd1d392ffe6f8193627168279441fb868555823ac5aa75c41f2d9e74" => :yosemite
    sha256 "3688f280ef8e85f1ff681ed03cf111a6cd28d58977fcdf7bed5a7ac2e61f7a01" => :mavericks
    sha256 "b94cb5912e23a86a475a10114bf14da05fcbbb6b5b85584998f566fc64c01461" => :mountain_lion
  end

  option "with-tests", "Verify the build using the testsuite."
  deprecated_option "tests" => "with-tests"

  resource "gmp" do
    url "http://ftpmirror.gnu.org/gmp/gmp-6.0.0a.tar.bz2"
    mirror "https://gmplib.org/download/gmp/gmp-6.0.0a.tar.bz2"
    mirror "https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2"
    sha256 "7f8e9a804b9c6d07164cf754207be838ece1219425d64e28cfa3e70d5c759aaf"
  end

  if MacOS.version <= :lion
    fails_with :clang do
      cause <<-EOS.undent
        Fails to bootstrap ghc-cabal. Error is:
          libraries/Cabal/Cabal/Distribution/Compat/Binary/Class.hs:398:14:
              The last statement in a 'do' block must be an expression
                n <- get :: Get Int getMany n
      EOS
    end
  end

  resource "binary" do
    if OS.linux?
      # Using 7.10.1 gives the error message:
      # BFD: dist-install/build/stj2R30K: Not enough room for program headers, try linking with -N
      # strip:dist-install/build/stj2R30K[.note.gnu.build-id]: Bad value
      url "http://downloads.haskell.org/~ghc/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2"
      sha256 "398dd5fa6ed479c075ef9f638ef4fc2cc0fbf994e1b59b54d77c26a8e1e73ca0"
    elsif MacOS.version <= :lion
      url "https://downloads.haskell.org/~ghc/7.6.3/ghc-7.6.3-x86_64-apple-darwin.tar.bz2"
      sha256 "f7a35bea69b6cae798c5f603471a53b43c4cc5feeeeb71733815db6e0a280945"
    else
      url "https://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-x86_64-apple-darwin.tar.xz"
      sha256 "ef0f00885096e3621cec84a112dfae050cf546ad39bdef29a7719407c6bc5b36"
    end
  end

  resource "testsuite" do
    url "https://downloads.haskell.org/~ghc/7.10.2/ghc-7.10.2-testsuite.tar.xz"
    sha256 "8b4885d376ca635935b49d4e36e2fa6f07164563ea496eac5fffa0ac926ae962"
  end

  def install
    # Build a static gmp rather than in-tree gmp, otherwise it links to brew's.
    gmp = libexec/"integer-gmp"

    # MPN_PATH: The lowest common denomenator asm paths that work on Darwin,
    # corresponding to Yonah and Merom. Obviates --disable-assembly.
    ENV["MPN_PATH"] = "x86_64/fastsse x86_64/core2 x86_64 generic" if build.bottle?

    # GMP *does not* use PIC by default without shared libs  so --with-pic
    # is mandatory or else you'll get "illegal text relocs" errors.
    resource("gmp").stage do
      system "./configure", "--prefix=#{gmp}", "--with-pic", "--disable-shared"
      system "make"
      system "make", "check"
      ENV.deparallelize { system "make", "install" }
    end

    args = ["--with-gmp-includes=#{gmp}/include",
            "--with-gmp-libraries=#{gmp}/lib",
            "--with-ld=ld", # Avoid hardcoding superenv's ld.
            "--with-gcc=#{ENV.cc}"] # Always.

    if ENV.compiler == :clang
      args << "--with-clang=#{ENV.cc}"
    elsif ENV.compiler == :llvm
      args << "--with-gcc-4.2=#{ENV.cc}"
    end

    resource("binary").stage do
      # Change the dynamic linker and RPATH of the binary executables.
      if OS.linux? && Formula["glibc"].installed?
        keg = Keg.new(prefix)
        Dir["ghc/stage2/build/tmp/ghc-stage2", "libraries/*/dist-install/build/*.so", "rts/dist/build/*.so*", "utils/*/dist*/build/tmp/*"].each { |s|
          file = Pathname.new(s)
          keg.change_rpath(file, HOMEBREW_PREFIX.to_s) if file.mach_o_executable? || file.dylib?
        }
      end

      binary = buildpath/"binary"

      system "./configure", "--prefix=#{binary}", *args
      ENV.deparallelize { system "make", "install" }

      ENV.prepend_path "PATH", binary/"bin"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make"

    if build.with? "tests"
      resource("testsuite").stage { buildpath.install Dir["*"] }
      cd "testsuite" do
        system "make", "clean"
        system "make", "CLEANUP=1", "THREADS=#{ENV.make_jobs}", "fast"
      end
    end

    ENV.deparallelize { system "make", "install" }
  end

  test do
    (testpath/"hello.hs").write('main = putStrLn "Hello Homebrew"')
    system "runghc", testpath/"hello.hs"
  end
end
