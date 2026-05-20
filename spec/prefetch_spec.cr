require "./spec_helper"

Spectator.describe Prefetch do
  context "offline output parsing" do
    it "parses nix-prefetch-git JSON" do
      output = <<-JSON
      {
        "url": "https://github.com/example/repo.git",
        "rev": "abc123",
        "sha256": "0000000000000000000000000000000000000000000000000000"
      }
      JSON

      expect(Prefetch.parse_git(output)).to eq(
        "0000000000000000000000000000000000000000000000000000"
      )
    end

    it "parses nix-prefetch-hg plain hash output" do
      expect(Prefetch.parse_hg("abcdefghijklmnopqrstuvwxyz0123456789abcdefghij\n")).to eq(
        "abcdefghijklmnopqrstuvwxyz0123456789abcdefghij"
      )
    end

    it "parses nix-prefetch-fossil JSON" do
      output = <<-JSON
      {
        "url": "https://example.com/repo",
        "rev": "deadbeef",
        "sha256": "1111111111111111111111111111111111111111111111111111"
      }
      JSON

      expect(Prefetch.parse_fossil(output)).to eq(
        "1111111111111111111111111111111111111111111111111111"
      )
    end

    it "falls back to hash when fossil JSON omits sha256" do
      output = <<-JSON
      {
        "hash": "2222222222222222222222222222222222222222222222222222"
      }
      JSON

      expect(Prefetch.parse_fossil(output)).to eq(
        "2222222222222222222222222222222222222222222222222222"
      )
    end
  end
end
