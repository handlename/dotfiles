NIX_FLAGS := --extra-experimental-features "nix-command flakes"
NIX_CMD := nix $(NIX_FLAGS)

setup:
	$(MAKE) install/nix
	$(MAKE) install/home-manager

install/nix:
	curl -L https://nixos.org/nix/install | sh

install/home-manager:
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install

build/home:
	$(NIX_CMD) run nixpkgs#home-manager -- build --flake .#myhome

switch:
	$(MAKE) switch/home
	$(MAKE) switch/darwin

switch/home: update
	$(NIX_CMD) run nixpkgs#home-manager -- switch $(NIX_FLAGS) --flake .#myhome

switch/darwin: update
	$(NIX_CMD) run nix-darwin -- switch --flake .#macbook-intel

update:
	$(NIX_CMD) flake update

gc:
	$(NIX_CMD) store gc
