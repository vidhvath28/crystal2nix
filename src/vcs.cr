module Crystal2Nix
  enum VcsType
    Git
    Hg
    Fossil

    def to_s
      case self
      when Git    then "git"
      when Hg     then "hg"
      when Fossil then "fossil"
      end
    end

    def self.from_lock_key(key : String) : VcsType
      case key
      when "git"    then Git
      when "hg"     then Hg
      when "fossil" then Fossil
      else
        raise ArgumentError.new("Unsupported VCS lock key: #{key}")
      end
    end
  end
end
