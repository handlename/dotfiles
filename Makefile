NIX_FLAGS := --extra-experimental-features "nix-command flakes"
NIX_CMD := nix $(NIX_FLAGS)
PROFILE := myhome

setup:
	$(MAKE) install/nix
	$(MAKE) install/home-manager
	$(MAKE) install/nix-darwin

install/nix:
	curl -L https://nixos.org/nix/install | sh

install/home-manager:
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

install/nix-darwin:
	nix-channel --add https://github.com/LnL7/nix-darwin/archive/refs/heads/nix-darwin-24.11.tar.gz nix-darwin
	nix-channel --update

build/home:
	$(NIX_CMD) run nixpkgs#home-manager -- build --flake .#myhome

switch:
	$(MAKE) switch/home
	$(MAKE) switch/darwin

switch/home: update
	$(NIX_CMD) run nixpkgs#home-manager -- switch $(NIX_FLAGS) --flake .#$(PROFILE)

switch/darwin: update
	sudo $(NIX_CMD) run nix-darwin -- switch --flake .#macbook

update:
	$(NIX_CMD) flake update

gc:
	$(NIX_CMD) store gc
