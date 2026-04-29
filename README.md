# Herd CLI

A command-line interface for the [Herd](https://herd.eco) platform. Explore blockchains, inspect contracts, analyze wallets, query transactions, and author HAL expressions -- directly from your terminal.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash
```

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash -s -- --version 0.7.0
```

### Manual download

Download a binary for your platform from the [latest release](https://github.com/herd-labs/herd-cli/releases/latest), make it executable, and move it to a directory in your PATH:

```bash
chmod +x herd-*
mv herd-* ~/.herd/bin/herd
```

### Supported platforms

| Platform       | Architecture |
| -------------- | ------------ |
| macOS (Darwin) | x64, arm64   |
| Linux          | x64, arm64   |

## Quick start

```bash
# Authenticate with the Herd platform
herd login

# Check who you are
herd whoami

# Look up contract metadata
herd contract metadata 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984

# Inspect a transaction
herd tx query 0xabc123...

# Get a wallet overview
herd wallet overview 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045

# Simulate a HAL expression
herd hal simulate '["do", ["define", "x", 42], "x"]'

# Search for actions
herd hal search "uniswap swap"

# Read documentation
# (Web route: https://herd.eco/SKILL.md)
herd docs read
```

## Authentication

The CLI uses OAuth 2.0 with PKCE. Run `herd login` to authenticate via your browser. Tokens are stored at `~/.herd/credentials.json`.

For CI/CD, set `HERD_ACCESS_TOKEN` or `HERD_API_KEY` environment variables to skip the interactive flow.

## Commands

| Command | Description |
| --- | --- |
| `herd login` | Authenticate via browser-based OAuth |
| `herd logout` | Log out and clear credentials |
| `herd whoami` | Show the authenticated user |
| `herd contract metadata <address>` | Get contract metadata and ABI |
| `herd contract deployed <address>` | List contracts deployed by an address |
| `herd contract diff <address>` | Diff upgradeable contract versions |
| `herd wallet overview <address>` | Wallet overview (type, balances, tx count) |
| `herd wallet tokens <address> <token>` | Token transfer activity |
| `herd wallet transactions [<address>] [--to …]` | Transaction activity (caller or callee via `--to`) |
| `herd tx query <hash>` | Full transaction inspection |
| `herd tx latest <address> <sig>` | Latest transactions by signature |
| `herd hal simulate <expr>` | Simulate a HAL expression |
| `herd hal search <query>` | Search actions and adapters |
| `herd hal get <id>` | Get an action or adapter |
| `herd hal create action <name> <expr>` | Create a new action |
| `herd hal update action <id>` | Update an action |
| `herd hal delete <id>` | Delete an action or adapter |
| `herd bookmarks list` | List saved bookmarks |
| `herd docs read` | Browse platform documentation |

Most commands support `--format json|pretty|table` and `--blockchain <chain>`.

Run `herd <command> --help` for full options.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `HERD_API_BASE_URL` | `https://api.herd.eco` | Base URL for the Herd API |
| `HERD_ACCESS_TOKEN` | -- | Override access token (skips OAuth) |
| `HERD_API_KEY` | -- | Override API key |

## Uninstall

```bash
rm -rf ~/.herd/bin/herd
```

Remove the PATH line from your shell rc file (`~/.zshrc`, `~/.bashrc`, etc.) if it was added by the installer.

## License

Proprietary. See [herd.eco](https://herd.eco) for terms.
