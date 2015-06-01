require "formula"

class Tutum < Formula
  homepage "https://www.tutum.co/"
  url "https://pypi.python.org/packages/source/t/tutum/tutum-0.15.0.1.tar.gz"
  sha256 "399cff8b5b25c1b2fa686d2214ae18dc09c410a070f17fa347b64940c4be0c79"

  bottle do
    cellar :any
    sha256 "2e7bbf6a3408f0ca3a408da1f0aff4534c67188cc6fc2e315daa78aa11529f94" => :yosemite
    sha256 "48fd8a003f8ac8189bd6142717c49b981fb0efd78bb7926f85f2b1cb81551537" => :mavericks
    sha256 "481402fde6caf702eb314f9ca3f7436fb8138169b3b04eabeda8ba3a0c79faae" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"

  resource "ago" do
    url "https://pypi.python.org/packages/source/a/ago/ago-0.0.6.tar.gz"
    sha256 "a64811a5a44cd3ba687d800986edf0f7a97859b8da75d3347c915b58b0869b44"
  end

  resource "docker-py" do
    url "https://pypi.python.org/packages/source/d/docker-py/docker-py-1.2.2.tar.gz"
    sha256 "4494d699059559118417da192a3d4bf015b097f7b589c48e253c12b4c61e5ef0"
  end

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz"
    sha256 "e713da45c96ca53a3a8b48140d4120374db622df16ab71759c9ceb5b8d46fe7c"
  end

  resource "python-tutum" do
    url "https://pypi.python.org/packages/source/p/python-tutum/python-tutum-0.15.0.1.tar.gz"
    sha256 "42f309124859d13b3edb2d604ee316c27bbe0c4708e2807a8f67262f9bdc68a4"
  end

  resource "backports.ssl-match-hostname" do
    url "https://pypi.python.org/packages/source/b/backports.ssl_match_hostname/backports.ssl_match_hostname-3.4.0.2.tar.gz"
    sha256 "07410e7fb09aab7bdaf5e618de66c3dac84e2e3d628352814dc4c37de321d6ae"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "python-dateutil" do
    url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.2.tar.gz"
    sha256 "eec865307ebe7f329a6a9945c15453265a449cdaaf3710340828a1934d53e468"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.7.0.tar.gz"
    sha256 "398a3db6d61899d25fd4a06c6ca12051b0ce171d705decd7ed5511517b4bb93d"
  end

  resource "tabulate" do
    url "https://pypi.python.org/packages/source/t/tabulate/tabulate-0.7.2.tar.gz"
    sha256 "532ccab8d9e4659a5f016d84814df86cc04763785e9de2739e890d956dc82d8f"
  end

  resource "websocket-client" do
    url "https://pypi.python.org/packages/source/w/websocket-client/websocket_client-0.31.0.tar.gz"
    sha256 "ddbba49fe9f185dec6a80a536831fa781e10e1d946eef20ebcccd75b943c6ea6"
  end

  resource "future" do
    url "https://pypi.python.org/packages/source/f/future/future-0.14.3.tar.gz"
    sha256 "62857d51881d97dd5492b9295b9f51d92108a52a4c88e2c40054c1d3e5995be9"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/tutum", "container"
  end
end
