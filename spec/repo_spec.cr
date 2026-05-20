require "./spec_helper"

Spectator.describe Repo do
  context "git commit" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.git-commit"))
          .shards["transliterator"]
      )
    }

    it "uses the commit as revision" do
      expect(repo.rev).to eq("46c4c14594057dbcfaf27e7e7c8c164d3f0ce3f1")
    end

    it "detects git as the VCS type" do
      expect(repo.vcs_type).to eq(Crystal2Nix::VcsType::Git)
    end

    it "normalizes the repository URL" do
      expect(repo.url).to eq("https://github.com/cadmiumcr/transliterator.git")
    end
  end

  context "git tag version" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.git"))
          .shards["json_mapping"]
      )
    }

    it "prefixes version references with v" do
      expect(repo.rev).to eq("v0.1.1")
    end
  end

  context "mercurial commit" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.hg"))
          .shards["hello"]
      )
    }

    it "uses the commit as revision" do
      expect(repo.rev).to eq("82e55d328c8ca4ee16520036c0aaace03a5beb65")
    end

    it "detects hg as the VCS type" do
      expect(repo.vcs_type).to eq(Crystal2Nix::VcsType::Hg)
    end

    it "keeps the mercurial repository URL" do
      expect(repo.url).to eq("https://www.mercurial-scm.org/repo/hello")
    end
  end

  context "mercurial tag version" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.hg-tag"))
          .shards["hello"]
      )
    }

    it "prefixes version references with v" do
      expect(repo.rev).to eq("v0.0.0")
    end
  end

  context "fossil commit" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.fossil"))
          .shards["docmessage"]
      )
    }

    it "uses the commit as revision" do
      expect(repo.rev).to eq("d41d8cd98f00b204e9800998ecf8427e")
    end

    it "detects fossil as the VCS type" do
      expect(repo.vcs_type).to eq(Crystal2Nix::VcsType::Fossil)
    end
  end

  context "fossil tag version" do
    let(:repo) {
      Crystal2Nix::Repo.new(
        Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.fossil-tag"))
          .shards["docmessage"]
      )
    }

    it "prefixes version references with v" do
      expect(repo.rev).to eq("v1.0.0")
    end
  end
end

Spectator.describe Shard do
  it "rejects lock entries with multiple VCS keys" do
    shard = Crystal2Nix::Shard.new(
      git: "https://example.com/a.git",
      hg: "https://example.com/b",
      fossil: nil,
      version: "1.0.0"
    )

    expect_raises(Crystal2Nix::Error) { shard.vcs_type }
  end
end
