module Crystal2Nix
  class Prefetch
    def self.sha256(repo : Repo) : String
      case repo.vcs_type
      when .git?
        prefetch_git(repo)
      when .hg?
        prefetch_hg(repo)
      when .fossil?
        prefetch_fossil(repo)
      end
    end

    def self.parse_git(output : String) : String
      PrefetchJSON.from_json(output).sha256
    end

    def self.parse_hg(output : String) : String
      hash = output.strip
      raise Error.new("nix-prefetch-hg produced no hash output") if hash.empty?
      hash
    end

    def self.parse_fossil(output : String) : String
      json = PrefetchJSON.from_json(output)
      json.sha256 || json.hash || raise Error.new("nix-prefetch-fossil JSON missing sha256/hash")
    end

    def self.prefetch_git(repo : Repo) : String
      args = [
        "--no-deepClone",
        "--url", repo.url,
        "--rev", repo.rev,
      ]
      parse_git run("nix-prefetch-git", args)
    end

    def self.prefetch_hg(repo : Repo) : String
      parse_hg run("nix-prefetch-hg", [repo.url, repo.rev])
    end

    def self.prefetch_fossil(repo : Repo) : String
      args = [
        "--url", repo.url,
        "--rev", repo.rev,
      ]
      parse_fossil run("nix-prefetch-fossil", args)
    end

    def self.run(command : String, args : Array(String)) : String
      output = IO::Memory.new
      error = IO::Memory.new
      status = Process.run(command, args: args, output: output, error: error)

      unless status.success?
        STDERR.puts error.to_s unless error.to_s.empty?
        raise Error.new("#{command} failed (exit #{status.exit_code})")
      end

      output.to_s
    end
  end
end
