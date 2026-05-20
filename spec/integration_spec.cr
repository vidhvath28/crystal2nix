require "./spec_helper"
require "fileutils"
require "random/secure"

Spectator.describe "online prefetch integration" do
  def skip_unless_online
    unless Crystal2Nix::SpecSupport.nix_store_available?
      pending "Set CRYSTAL2NIX_ONLINE_TESTS=1 with Nix available to run network prefetch tests"
    end
  end

  def with_temp_lock(contents : String, &)
    dir = File.join(Dir.tempdir, "crystal2nix-spec-#{Random::Secure.hex(6)}")
    Dir.mkdir_p(dir)
    begin
      lock = File.join(dir, "shard.lock")
      File.write(lock, contents)
      yield lock, dir
    ensure
      FileUtils.rm_rf(dir) if Dir.exists?(dir)
    end
  end

  context "git" do
    it "prefetches a public git repository" do
      skip_unless_online

      repo = Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.git"))
          .shards["json_mapping"]
      )

      sha256 = Crystal2Nix::Prefetch.sha256(repo)
      expect(sha256).to match(Crystal2Nix::SpecSupport::NIX_SHA256)
    end
  end

  context "mercurial" do
    it "prefetches a public mercurial repository" do
      skip_unless_online

      repo = Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.hg"))
          .shards["hello"]
      )

      sha256 = Crystal2Nix::Prefetch.sha256(repo)
      expect(sha256).to match(Crystal2Nix::SpecSupport::NIX_SHA256)
    end
  end

  context "fossil" do
    it "prefetches a public fossil repository by tag" do
      skip_unless_online

      repo = Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.fossil-tag"))
          .shards["docmessage"]
      )

      sha256 = Crystal2Nix::Prefetch.sha256(repo)
      expect(sha256).to match(Crystal2Nix::SpecSupport::NIX_SHA256)
    end
  end

  context "worker end-to-end" do
    it "writes shards.nix for mixed VCS lock files" do
      skip_unless_online

      with_temp_lock(Crystal2Nix::SpecSupport.fixture("shard.lock.mixed")) do |lock, dir|
        Dir.cd(dir) do
          Crystal2Nix::Worker.new(lock).run
        end

        output = File.read(File.join(dir, Crystal2Nix::SHARDS_NIX))
        expect(output).to contain("json_mapping")
        expect(output).not_to contain(%(type = "git"))
        expect(output).to contain(%(type = "hg"))
        expect(output).to match(Crystal2Nix::SpecSupport::NIX_SHA256)
      end
    end
  end
end
