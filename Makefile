setup:
	$(MAKE) install/nix
	$(MAKE) install/home-manager

install/nix:
	curl -L https://nixos.org/nix/install | sh

install/home-manager:
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update

build/home:
	nix run nixpkgs#home-manager -- build --flake .#myhome

switch:
	$(MAKE) switch/home
	$(MAKE) switch/darwin

switch/home: update
	nix run nixpkgs#home-manager -- switch --flake .#myhome

switch/darwin: update
	nix run nix-darwin -- switch --flake .#macbook

update:
	nix flake update

gc:
	nix store gc
