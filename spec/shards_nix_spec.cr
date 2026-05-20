require "./spec_helper"

Spectator.describe ShardsNixWriter do
  it "writes git entries without a type field for nixpkgs compatibility" do
    repo = Crystal2Nix::Repo.new(
      Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.git"))
        .shards["json_mapping"]
    )

    lines = ShardsNixWriter.entry_lines("json_mapping", repo, "abc123")
    expect(lines.join("\n")).not_to contain("type =")
    expect(lines.join("\n")).to contain(%(url = "https://github.com/crystal-lang/json_mapping.cr.git";))
    expect(lines.join("\n")).to contain(%(rev = "v0.1.1";))
    expect(lines.join("\n")).to contain(%(sha256 = "abc123";))
  end

  it "writes mercurial entries with a type field" do
    repo = Crystal2Nix::Repo.new(
      Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.hg"))
        .shards["hello"]
    )

    lines = ShardsNixWriter.entry_lines("hello", repo, "def456")
    expect(lines.join("\n")).to contain(%(type = "hg";))
    expect(lines.join("\n")).to contain(%(url = "https://www.mercurial-scm.org/repo/hello";))
    expect(lines.join("\n")).to contain(
      %(rev = "82e55d328c8ca4ee16520036c0aaace03a5beb65";)
    )
  end

  it "writes fossil entries with a type field" do
    repo = Crystal2Nix::Repo.new(
      Crystal2Nix::Shard.from_yaml(Crystal2Nix::SpecSupport.fixture("shard.lock.fossil"))
        .shards["docmessage"]
    )

    lines = ShardsNixWriter.entry_lines("docmessage", repo, "ghi789")
    expect(lines.join("\n")).to contain(%(type = "fossil";))
    expect(lines.join("\n")).to contain(
      %(url = "https://chiselapp.com/user/rkeene/repository/docmessage";)
    )
  end

  it "escapes double quotes in attribute values" do
    repo = Crystal2Nix::Repo.new(
      git: "https://example.com/repo\"special.git",
      hg: nil,
      fossil: nil,
      version: "1.0.0"
    )

    lines = ShardsNixWriter.entry_lines("weird", repo, "hash\"value")
    expect(lines.join("\n")).to contain(%(url = "https://example.com/repo\"special.git";))
    expect(lines.join("\n")).to contain(%(sha256 = "hash\"value";))
  end
end
