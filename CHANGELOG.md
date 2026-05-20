### v0.4.0
(IN PROGRESS)

Major change(s):

- Support Mercurial (`hg`) and Fossil (`fossil`) dependencies from `shard.lock`, in
  addition to Git.
- Emit `type = "hg"` or `type = "fossil"` in `shards.nix` for non-Git sources so
  nixpkgs can select `fetchhg` / `fetchFossil`.
- Git entries remain unchanged for compatibility with existing `fetchgit` usage.

Minor change(s):

- Add offline unit tests for lock parsing, output formatting, and prefetch output parsing.
- Add online integration tests (enabled with `CRYSTAL2NIX_ONLINE_TESTS=1` or the
  `checks.specs-online` flake check) that run real `nix-prefetch-*` commands.
- Document VCS support and nixpkgs integration in the README.

### v0.3.1 2025-07-09

Minor change(s):
- Quote attribute names in shards.nix to allow dots in shard names.

### v0.3.0 2022-04-09

Major change(s):

Create a new shards.nix format that can be used by the nixpkgs `fetchgit`
fetcher instead of `fetchFromGitHub` to allow fetching from all git sources.

Minor change(s):
- Build using nix and provide flake.nix for an easy development experience.
- Add some basic tests

### v0.2.0 2022-03-29

- Split the application into worker and CLI sections. This allows us to
  `require` everything for use in testing without having to actually execute the
  code.

### v0.1.1 2021-03-20

- Support for commits rather then released versions in the new v2 format.

### v0.1.0 2020-12-2020

- Initial outside release after having lived in the nixpkgs repository.
