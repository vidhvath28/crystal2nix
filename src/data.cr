module Crystal2Nix
  class Error < Exception; end

  class PrefetchJSON
    include JSON::Serializable

    property sha256 : String?
    property hash : String?
  end

  class ShardLock
    include YAML::Serializable

    property version : Float32
    property shards : Hash(String, Shard)
  end

  class Shard
    include YAML::Serializable

    property git : String?
    property hg : String?
    property fossil : String?
    property version : String

    def vcs_type : VcsType
      sources = {@git, @hg, @fossil}
      selected = sources.compact
      if selected.size != 1
        keys = [] of String
        keys << "git" if @git
        keys << "hg" if @hg
        keys << "fossil" if @fossil
        raise Error.new(
          "Shard lock entry must have exactly one of git, hg, or fossil (found: #{keys.join(", ")})"
        )
      end

      VcsType.from_lock_key(
        @git ? "git" : @hg ? "hg" : "fossil"
      )
    end

    def source_url : String
      @git || @hg || @fossil || raise Error.new("Shard lock entry is missing a repository URL")
    end
  end
end
