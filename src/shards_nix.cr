module Crystal2Nix
  class ShardsNixWriter
    def self.write(path : String, entries : Array({String, Repo, String}))
      File.open(path, "w") do |file|
        file.puts "{"
        entries.each do |(name, repo, sha256)|
          file.puts entry_lines(name, repo, sha256).join("\n")
        end
        file.puts "}"
      end
    end

    def self.entry_lines(name : String, repo : Repo, sha256 : String) : Array(String)
      lines = [] of String
      lines << %(  "#{escape_nix_string(name)}" = {)
      lines << %(    type = "#{repo.vcs_type}";) unless repo.vcs_type.git?
      lines << %(    url = "#{escape_nix_string(repo.url)}";)
      lines << %(    rev = "#{escape_nix_string(repo.rev)}";)
      lines << %(    sha256 = "#{escape_nix_string(sha256)}";)
      lines << "  };"
      lines
    end

    def self.escape_nix_string(value : String) : String
      value.gsub('"', '\\"')
    end
  end
end
