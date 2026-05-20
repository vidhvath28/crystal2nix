module Crystal2Nix
  class Repo
    getter vcs_type : VcsType
    getter rev : String
    @url : URI

    GIT_COMMIT_VERSION = /^(?<version>.+)\+git\.commit\.(?<rev>.+)$/
    HG_COMMIT_VERSION = /^(?<version>.+)\+hg\.commit\.(?<rev>.+)$/
    FOSSIL_COMMIT_VERSION = /^(?<version>.+)\+fossil\.commit\.(?<rev>.+)$/

    def initialize(entry : Shard)
      @vcs_type = entry.vcs_type
      @url = URI.parse(entry.source_url).normalize
      @rev = resolve_rev(entry.version, @vcs_type)
    end

    def url : String
      @url.to_s
    end

    private def resolve_rev(version : String, vcs : VcsType) : String
      case vcs
      when .git?
        rev_from_version(version, GIT_COMMIT_VERSION)
      when .hg?
        rev_from_version(version, HG_COMMIT_VERSION)
      when .fossil?
        rev_from_version(version, FOSSIL_COMMIT_VERSION)
      end
    end

    private def rev_from_version(version : String, commit_pattern : Regex) : String
      if version =~ commit_pattern
        $~["rev"]
      else
        "v#{version}"
      end
    end
  end
end
