# crystal2nix

Helps nixify Crystal projects by converting `shard.lock` into a `shards.nix` file
for reproducible Nix builds.

## Supported version control systems

| VCS | `shard.lock` key | Prefetch command | `shards.nix` |
|-----|------------------|------------------|--------------|
| Git | `git` | `nix-prefetch-git` | `url`, `rev`, `sha256` (no `type`; nixpkgs-compatible) |
| Mercurial | `hg` | `nix-prefetch-hg` | `type = "hg"`, `url`, `rev`, `sha256` |
| Fossil | `fossil` | `nix-prefetch-fossil` | `type = "fossil"`, `url`, `rev`, `sha256` |

Shards encodes pinned commits as `version+git.commit.<hash>`, `version+hg.commit.<hash>`,
or `version+fossil.commit.<hash>`. Tag or release versions are written as `v<version>` for
the Nix `rev` field.

## Installation

You don't need to install it. With Nix installed you can just run it:

```bash
nix-shell -p crystal2nix nix-prefetch-git nix-prefetch-hg nix-prefetch-fossil git mercurial fossil --run crystal2nix
```

For Mercurial or Fossil dependencies, the matching prefetch helper and VCS client must be on `PATH`.

## Usage

From a project directory that contains `shard.lock`:

```bash
crystal2nix
```

Use a different lock file:

```bash
crystal2nix --lock-file=shard.lock
```

Example `shards.nix` output for mixed dependencies:

```nix
{
  "my-git-dep" = {
    url = "https://github.com/example/lib.git";
    rev = "v1.0.0";
    sha256 = "...";
  };
  "my-hg-dep" = {
    type = "hg";
    url = "https://hg.example.org/lib";
    rev = "abcdef0123456789...";
    sha256 = "...";
  };
  "my-fossil-dep" = {
    type = "fossil";
    url = "https://fossil.example.org/lib";
    rev = "v1.0.0";
    sha256 = "...";
  };
}
```

### nixpkgs integration

Current [nixpkgs](https://github.com/NixOS/nixpkgs) Crystal builds use `fetchgit` for every
`shards.nix` entry that has a `url` attribute. Git entries from crystal2nix stay compatible
with that behavior.

For Mercurial and Fossil shards, extend the dependency fetcher in `build-package.nix` along
these lines:

```nix
fetchShard = value:
  if (value.type or "git") == "hg" then
    fetchhg value
  else if value.type == "fossil" then
    fetchFossil value
  else
    fetchgit value;
```

## Development

```bash
nix develop
shards install
make build
make check          # offline unit tests
make test-online    # network + nix-store prefetch tests
```

Or with flakes:

```bash
nix build .#crystal2nix
nix build .#checks.specs-offline
CRYSTAL2NIX_ONLINE_TESTS=1 nix build .#checks.specs-online
```

We welcome all help with open arms!

## Contributing

1. Fork it (<https://github.com/nix-community/crystal2nix/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Michael Fellinger](https://github.com/manveru)
- [Peter Hoeg](https://github.com/peterhoeg)
- [Voob of Doom](https://github.com/voobsta)
