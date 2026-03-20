# Herd CLI

A command-line interface for the [Herd](https://herd.eco) platform. Explore blockchains, inspect contracts, analyze wallets, query transactions, and author HAL expressions -- directly from your terminal.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash
```

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash -s -- --version 0.4.0
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

# Evaluate a HAL expression
herd hal evaluate --wallet 0xYourWallet '["do", ["define", "x", 42], "x"]'

# Search for actions
herd hal search "uniswap swap"

# Read documentation
herd docs read
```

## Authentication

The CLI uses OAuth 2.0 with PKCE. Run `herd login` to authenticate via your browser. Tokens are stored at `~/.herd/credentials.json`.

For CI/CD, set `HERD_ACCESS_TOKEN` or `HERD_API_KEY` environment variables to skip the interactive flow.

## Commands

### Auth

| Command | Description |
| --- | --- |
| `herd login` | Authenticate via browser-based OAuth |
| `herd logout` | Log out and clear stored credentials |
| `herd whoami` | Show the authenticated user |
| `herd update [--version text]` | Update herd to the latest version |

### Contract

| Command | Description |
| --- | --- |
| `herd contract metadata <address>` | Get contract metadata, ABI, and summaries |
| `herd contract deployed <address>` | List contracts deployed by an address |
| `herd contract roles <address>` | Get role/permission topology for a contract |
| `herd contract diff <address>` | Show semantic diffs between contract implementation versions |
| `herd contract code --query <text> --contract-address <address>` | Search contract source code or return full source |

### Wallet

| Command | Description |
| --- | --- |
| `herd wallet overview <address>` | Wallet overview with type, balances, and activity stats |
| `herd wallet tokens <address> <token>` | Token activity for an address |
| `herd wallet transactions <address>` | Transaction activity for an address |
| `herd wallet deployed-contracts <address>` | Deployed contracts for an address |

### Transactions

| Command | Description |
| --- | --- |
| `herd tx query <hash>` | Query and inspect a transaction by hash |
| `herd tx latest --contractAddress <address>` | Get latest transactions calling a function or emitting an event |

### HAL

| Command | Description |
| --- | --- |
| `herd hal evaluate --wallet <address> [<expression>]` | Evaluate a HAL expression in a sandboxed Tevm fork |
| `herd hal evaluate-existing --wallet <address> <action-id>` | Simulate an existing action by ID in a sandboxed Tevm fork |
| `herd hal search [<query>]` | Search actions and adapters |
| `herd hal get <id>` | Get an action or adapter by ID |
| `herd hal search-collections [<query>]` | Search collections |
| `herd hal get-collection <id>` | Get a collection by ID |
| `herd hal get-code-block <id>` | Get a code block by ID |
| `herd hal execute-code-block <id>` | Execute a code block |
| `herd hal create action <name> [<expression>]` | Create a new action from a HAL expression |
| `herd hal create adapter <name> [<expression>]` | Create a new adapter from a HAL expression |
| `herd hal create code-block <name> [<code>]` | Create a new code block |
| `herd hal create collection <name>` | Create a new collection |
| `herd hal update action <id>` | Update an existing action by ID |
| `herd hal update adapter <id>` | Update an existing adapter by ID |
| `herd hal update code-block <id>` | Update an existing code block by ID |
| `herd hal update collection <id>` | Update an existing collection by ID |
| `herd hal delete <id>` | Delete an action or adapter by ID |
| `herd hal delete-code-block <id>` | Delete a code block by ID |

### Bookmarks & Docs

| Command | Description |
| --- | --- |
| `herd bookmarks list` | List saved bookmarks |
| `herd bookmarks update --operation add\|edit\|remove --object-type contract\|transaction\|wallet <objectId>` | Add, edit, or remove a bookmark |
| `herd docs read [<doc-id>]` | Read documentation by document ID |

Most commands support `--format json|pretty|table` and `--blockchain ethereum|base`.

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
