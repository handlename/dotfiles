NIX_FLAGS :=
NIX_CMD := nix --extra-experimental-features "nix-command flakes" $(NIX_FLAGS)
PROFILE := current

setup:
	$(MAKE) install/nix
	$(MAKE) install/home-manager
	$(MAKE) install/nix-darwin

install/nix:
	curl -L https://nixos.org/nix/install | sh

install/home-manager:
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

install/nix-darwin:
	nix-channel --add https://github.com/LnL7/nix-darwin/archive/refs/heads/nix-darwin-25.05.tar.gz nix-darwin
	nix-channel --update

build/home:
	$(NIX_CMD) run nixpkgs#home-manager -- build --flake .#$(PROFILE)

switch:
	$(MAKE) switch/home
	$(MAKE) switch/darwin

switch/home:
	$(NIX_CMD) run nixpkgs#home-manager -- switch --flake .#$(PROFILE)

switch/darwin:
	sudo $(NIX_CMD) run nix-darwin -- switch --flake .#$(PROFILE)

update:
	$(NIX_CMD) flake update

gc:
	$(NIX_CMD) store gc
