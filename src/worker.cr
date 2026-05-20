module Crystal2Nix
  SHARDS_NIX = "shards.nix"

  class Worker
    def initialize(@lock_file : String)
    end

    def run
      entries = [] of {String, Repo, String}

      ShardLock.from_yaml(File.read(@lock_file)).shards.each do |key, value|
        repo = Repo.new(value)
        sha256 = Prefetch.sha256(repo)
        entries << {key, repo, sha256}
      rescue ex : Error
        STDERR.puts "ERROR: #{key}: #{ex.message}"
        exit 1
      end

      ShardsNixWriter.write(SHARDS_NIX, entries)
    end
  end
end
