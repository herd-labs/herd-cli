#!/usr/bin/env bash
set -euo pipefail

# Herd CLI installer
# Usage: curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash
#   or:  curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash -s -- --version 0.1.2

REPO="herd-labs/herd-cli"
BINARY_NAME="herd"
INSTALL_DIR="${HERD_INSTALL_DIR:-$HOME/.herd/bin}"
TAG_PREFIX="v"

# ─── Colors ───────────────────────────────────────────────────────────────────

if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  CYAN="$(tput setaf 6)"
  RESET="$(tput sgr0)"
else
  BOLD="" RED="" GREEN="" YELLOW="" CYAN="" RESET=""
fi

info()    { printf "%s%s▸%s %s\n" "$BOLD" "$CYAN"   "$RESET" "$1"; }
success() { printf "%s%s✓%s %s\n" "$BOLD" "$GREEN"  "$RESET" "$1"; }
warn()    { printf "%s%s!%s %s\n" "$BOLD" "$YELLOW" "$RESET" "$1"; }
error()   { printf "%s%s✗%s %s\n" "$BOLD" "$RED"    "$RESET" "$1" >&2; }
die()     { error "$1"; exit 1; }

# ─── Platform detection ───────────────────────────────────────────────────────

detect_platform() {
  local os arch

  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin) os="darwin" ;;
    Linux)  os="linux"  ;;
    MINGW*|MSYS*|CYGWIN*|Windows_NT)
      die "Windows is not supported. Use WSL instead: https://learn.microsoft.com/en-us/windows/wsl/install"
      ;;
    *) die "Unsupported operating system: $os" ;;
  esac

  case "$arch" in
    x86_64|amd64)  arch="x64"   ;;
    aarch64|arm64) arch="arm64" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac

  PLATFORM="${os}-${arch}"
}

# ─── Dependency checks ────────────────────────────────────────────────────────

check_deps() {
  if command -v curl >/dev/null 2>&1; then
    FETCH="curl"
  elif command -v wget >/dev/null 2>&1; then
    FETCH="wget"
  else
    die "Either curl or wget is required"
  fi
}

fetch_url() {
  local url="$1"
  if [ "$FETCH" = "curl" ]; then
    curl -fsSL "$url"
  else
    wget -qO- "$url"
  fi
}

download_file() {
  local url="$1" dest="$2"
  if [ "$FETCH" = "curl" ]; then
    curl -fsSL -o "$dest" "$url"
  else
    wget -qO "$dest" "$url"
  fi
}

# ─── Version resolution ──────────────────────────────────────────────────────

resolve_version() {
  local version="${1:-}"

  if [ -n "$version" ]; then
    version="${version#v}"
    TAG="${TAG_PREFIX}${version}"
    VERSION="$version"
    return
  fi

  info "Fetching latest version..."

  local api_url="https://api.github.com/repos/${REPO}/releases/latest"
  local response

  response="$(fetch_url "$api_url")" || die "Failed to fetch latest release from GitHub API"

  if command -v jq >/dev/null 2>&1; then
    TAG="$(printf '%s' "$response" | jq -r '.tag_name')"
  else
    TAG="$(printf '%s' "$response" | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"v[^"]*"' | head -1 | grep -o 'v[^"]*')"
  fi

  if [ -z "$TAG" ] || [ "$TAG" = "null" ]; then
    die "Could not determine latest version. Check https://github.com/${REPO}/releases"
  fi

  VERSION="${TAG#${TAG_PREFIX}}"
}

# ─── Installation ─────────────────────────────────────────────────────────────

install() {
  local artifact="${BINARY_NAME}-${PLATFORM}"
  local download_url="https://github.com/${REPO}/releases/download/${TAG}/${artifact}"
  local tmp_dir

  tmp_dir="$(mktemp -d)" || die "Failed to create temporary directory"
  trap 'rm -rf "$tmp_dir"' EXIT

  local tmp_file="${tmp_dir}/${artifact}"

  info "Downloading ${BINARY_NAME} v${VERSION} for ${PLATFORM}..."
  download_file "$download_url" "$tmp_file" || {
    die "Download failed. Verify the release exists: https://github.com/${REPO}/releases/tag/${TAG}"
  }

  # Verify it's a valid binary (not an HTML error page)
  if file "$tmp_file" 2>/dev/null | grep -qi "text\|html"; then
    die "Downloaded file is not a valid binary. The release may not exist for ${PLATFORM}."
  fi

  chmod +x "$tmp_file"

  # Verify the binary runs
  if ! "$tmp_file" --version >/dev/null 2>&1; then
    warn "Binary verification skipped (--version not supported)"
  fi

  mkdir -p "$INSTALL_DIR"
  mv "$tmp_file" "${INSTALL_DIR}/${BINARY_NAME}"

  success "Installed ${BINARY_NAME} v${VERSION} to ${INSTALL_DIR}/${BINARY_NAME}"
}

# ─── PATH setup ───────────────────────────────────────────────────────────────

ensure_path() {
  if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    return
  fi

  warn "${INSTALL_DIR} is not in your PATH"

  local shell_name
  shell_name="$(basename "${SHELL:-/bin/bash}")"

  local rc_file
  case "$shell_name" in
    zsh)  rc_file="$HOME/.zshrc"    ;;
    bash)
      if [ -f "$HOME/.bashrc" ]; then
        rc_file="$HOME/.bashrc"
      else
        rc_file="$HOME/.bash_profile"
      fi
      ;;
    fish) rc_file="$HOME/.config/fish/config.fish" ;;
    *)    rc_file="$HOME/.profile"  ;;
  esac

  local path_line="export PATH=\"${INSTALL_DIR}:\$PATH\""
  if [ "$shell_name" = "fish" ]; then
    path_line="set -gx PATH ${INSTALL_DIR} \$PATH"
  fi

  if [ -f "$rc_file" ] && grep -qF "$INSTALL_DIR" "$rc_file" 2>/dev/null; then
    info "PATH entry already in ${rc_file} (restart your shell to pick it up)"
    return
  fi

  printf '\n# Herd CLI\n%s\n' "$path_line" >> "$rc_file"
  success "Added ${INSTALL_DIR} to PATH in ${rc_file}"
  echo ""
  info "Run this to use herd now:"
  echo "  ${path_line}"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  local version=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --version|-v)
        [ $# -lt 2 ] && die "--version requires an argument"
        version="$2"
        shift 2
        ;;
      --help|-h)
        cat <<EOF
${BOLD}Herd CLI Installer${RESET}

${BOLD}Usage:${RESET}
  curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/herd-labs/herd-cli/main/install.sh | bash -s -- [options]

${BOLD}Options:${RESET}
  --version, -v <version>   Install a specific version (e.g., 0.1.2)
  --help, -h                Show this help message

${BOLD}Environment:${RESET}
  HERD_INSTALL_DIR          Override install directory (default: ~/.herd/bin)

EOF
        exit 0
        ;;
      *)
        die "Unknown option: $1 (use --help for usage)"
        ;;
    esac
  done

  echo ""
  printf "  %s ╻ ╻ ┏━╸ ┏━┓ ╺┳┓%s\n" "$BOLD" "$RESET"
  printf "  %s ┣━┫ ┣╸  ┣┳┛  ┃┃%s\n" "$BOLD" "$RESET"
  printf "  %s ╹ ╹ ┗━╸ ╹┗╸ ╺┻┛%s\n" "$BOLD" "$RESET"
  echo ""

  detect_platform
  check_deps
  resolve_version "$version"
  install
  ensure_path

  echo ""
  success "Installation complete! Run ${BOLD}herd --help${RESET} to get started."
  echo ""
}

main "$@"
