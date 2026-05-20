BINARY = bin/crystal2nix

default: build

$(BINARY): build

.PHONY: build
build: version.json
	@shards build

.PHONY: nix
nix: build
	@nix build .#crystal2nix

.PHONY: check
check: $(BINARY)
	@shards install
	@crystal spec spec/repo_spec.cr spec/prefetch_spec.cr spec/shards_nix_spec.cr

.PHONY: test-online
test-online: $(BINARY)
	@shards install
	@CRYSTAL2NIX_ONLINE_TESTS=1 crystal spec spec/integration_spec.cr

.PHONY: clean
clean:
	@rm -f $(BINARY)

.PHONY: run
run: $(BINARY)
	$(BINARY)

version.json: shard.yml
	@echo "{ \"version\": \"$$(shards version)\" }" > $@

shard.lock: shard.yml
	@shards install

shards.nix: shard.lock
	@$(BINARY)
