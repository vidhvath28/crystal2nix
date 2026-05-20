module Crystal2Nix::SpecSupport
  FIXTURES = File.expand_path("fixtures", __DIR__)

  def self.fixture(name : String) : String
    File.read(File.join(FIXTURES, name))
  end

  def self.online_tests_enabled? : Bool
    ENV["CRYSTAL2NIX_ONLINE_TESTS"]? == "1"
  end

  def self.nix_store_available? : Bool
    return false unless online_tests_enabled?
    Process.run("nix-store", args: ["--version"], output: Process::Redirect::Close).success?
  end

  NIX_SHA256 = /^[0-9a-z]{52}$/
end
