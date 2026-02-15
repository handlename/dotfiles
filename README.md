# dotfiles

Personal configuration files managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes), [Home Manager](https://github.com/nix-community/home-manager), and [nix-darwin](https://github.com/LnL7/nix-darwin).

> [!WARNING]
> These are @handlename's personal dotfiles. They are provided as-is with absolutely no warranty. Use at your own risk.

## Prerequisites

- macOS (aarch64-darwin)

## Setup

Install Nix, Home Manager, and nix-darwin:

```sh
make setup
```

This runs the following steps in order:

1. `make install/nix` — Install Nix
2. `make install/home-manager` — Add the Home Manager channel
3. `make install/nix-darwin` — Add the nix-darwin channel

## Usage

Apply configurations:

```sh
make switch
```

This applies both Home Manager and nix-darwin configurations. You can also apply them individually:

```sh
make switch/home    # Home Manager only
make switch/darwin  # nix-darwin only (requires sudo)
```

Other commands:

```sh
make build/home  # Build Home Manager configuration without applying
make update      # Update flake inputs
make gc          # Run Nix garbage collection
```

## Structure

```
.
├── flake.nix          # Flake definition (inputs and outputs)
├── flake.lock         # Pinned dependency versions
├── home.nix           # Home Manager configuration
├── configuration.nix  # Shared nix-darwin configuration
├── darwin.nix         # macOS-specific settings (defaults, Homebrew casks, etc.)
├── vars.nix           # Shared variables
├── Makefile           # Setup and build commands
├── modules/           # Per-application Home Manager modules
├── config/            # Extra configuration files (wezterm, claude, etc.)
└── codespaces/        # GitHub Codespaces setup scripts
```

## Codespaces

For GitHub Codespaces environments, a separate setup script is provided:

```sh
./install.sh
```

This script detects the Codespaces environment and runs `codespaces/install.sh`, which installs packages and configures tools for the Linux-based Codespaces environment.
