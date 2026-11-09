#!/usr/bin/env bash
set -euo pipefail

# Rux Multi-Platform Universal Installer
# Compatible with Linux (x86_64, aarch64), macOS (Intel, Apple Silicon)

REPO="bishwaxyz/ru"
VERSION="v1.0.0"
PREFIX="${RUX_INSTALL:-$HOME/.rux}"
MODIFY_PATH=true
LOCAL_MODE=false

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

print_banner() {
    cat << "EOF"
  ____            
 |  _ \ _   ___  __
 | |_) | | | \ \/ /
 |  _ <| |_| |>  < 
 |_| \_\\__,_/_/\_\
 The Sovereign Systems Programming Language
EOF
}

usage() {
    cat << EOF
Rux Universal Installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash [options]
  ./install.sh [options]

Options:
  --prefix <path>     Install to custom directory (default: ~/.rux)
  --version <ver>     Install specific version tag (default: ${VERSION})
  --local             Install from current local repository checkout
  --no-modify-path    Do not modify shell configuration files (.bashrc, .zshrc)
  -h, --help          Show this help message
EOF
    exit 0
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --local)
            LOCAL_MODE=true
            shift
            ;;
        --no-modify-path)
            MODIFY_PATH=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}" >&2
            usage
            ;;
    esac
done

detect_platform() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"

    case "${os}" in
        Linux)
            OS_TARGET="unknown-linux-musl"
            ;;
        Darwin)
            OS_TARGET="apple-darwin"
            ;;
        *)
            echo -e "${RED}Unsupported operating system: ${os}${RESET}" >&2
            exit 1
            ;;
    esac

    case "${arch}" in
        x86_64|amd64)
            ARCH_TARGET="x86_64"
            ;;
        aarch64|arm64)
            ARCH_TARGET="aarch64"
            ;;
        *)
            echo -e "${RED}Unsupported processor architecture: ${arch}${RESET}" >&2
            exit 1
            ;;
    esac

    PLATFORM="${ARCH_TARGET}-${OS_TARGET}"
}

update_shell_profile() {
    local target_bin="$1"
    local shell_configs=()

    if [ -n "${SHELL:-}" ]; then
        case "$(basename "${SHELL}")" in
            zsh)
                shell_configs+=("$HOME/.zshrc" "$HOME/.zshenv")
                ;;
            bash)
                shell_configs+=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
                ;;
            fish)
                shell_configs+=("$HOME/.config/fish/config.fish")
                ;;
        esac
    fi

    # Fallbacks
    shell_configs+=("$HOME/.profile" "$HOME/.bashrc")

    local path_line='export RUX_HOME="'"${PREFIX}"'"'
    local env_line='export PATH="$RUX_HOME/bin:$PATH"'
    local updated=false

    for cfg in "${shell_configs[@]}"; do
        if [ -f "${cfg}" ]; then
            if ! grep -q "RUX_HOME" "${cfg}" 2>/dev/null; then
                echo "" >> "${cfg}"
                echo "# Rux Programming Language Environment" >> "${cfg}"
                echo "${path_line}" >> "${cfg}"
                echo "${env_line}" >> "${cfg}"
                echo -e "  ${GREEN}✓${RESET} Updated ${CYAN}${cfg}${RESET}"
                updated=true
                break
            else
                updated=true
                break
            fi
        fi
    done

    if [ "${updated}" = false ]; then
        echo "" >> "$HOME/.profile"
        echo "# Rux Programming Language Environment" >> "$HOME/.profile"
        echo "${path_line}" >> "$HOME/.profile"
        echo "${env_line}" >> "$HOME/.profile"
        echo -e "  ${GREEN}✓${RESET} Configured ${CYAN}$HOME/.profile${RESET}"
    fi
}

main() {
    print_banner
    detect_platform

    echo -e "${BOLD}Installing Rux (${CYAN}${VERSION}${RESET}${BOLD}) for ${GREEN}${PLATFORM}${RESET}${BOLD}...${RESET}"
    echo -e "  Target directory: ${CYAN}${PREFIX}${RESET}"

    mkdir -p "${PREFIX}/bin"
    mkdir -p "${PREFIX}/lib"

    if [ "${LOCAL_MODE}" = true ] || [ -f "./bin/rux" ]; then
        echo -e "  Installing from local repository..."
        cp -f "./bin/rux" "${PREFIX}/bin/rux"
        chmod +x "${PREFIX}/bin/rux"
        
        if [ -f "./bin/ruxc" ]; then
            cp -f "./bin/ruxc" "${PREFIX}/bin/ruxc"
            chmod +x "${PREFIX}/bin/ruxc"
        fi

        if [ -d "./lib" ]; then
            cp -rf ./lib/* "${PREFIX}/lib/" 2>/dev/null || true
        fi
    else
        echo -e "  Downloading package from GitHub Releases..."
        TARBALL_NAME="rux-${VERSION}-${PLATFORM}.tar.gz"
        DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${TARBALL_NAME}"

        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "${TMP_DIR}"' EXIT

        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${TARBALL_NAME}"
        elif command -v wget >/dev/null 2>&1; then
            wget -qO "${TMP_DIR}/${TARBALL_NAME}" "${DOWNLOAD_URL}"
        else
            echo -e "${RED}Error: curl or wget is required to download Rux.${RESET}" >&2
            exit 1
        fi

        tar -xzf "${TMP_DIR}/${TARBALL_NAME}" -C "${TMP_DIR}"
        EXTRACT_DIR="${TMP_DIR}/rux-${VERSION}-${PLATFORM}"

        cp -f "${EXTRACT_DIR}/bin/rux" "${PREFIX}/bin/rux"
        chmod +x "${PREFIX}/bin/rux"
        
        if [ -f "${EXTRACT_DIR}/bin/ruxc" ]; then
            cp -f "${EXTRACT_DIR}/bin/ruxc" "${PREFIX}/bin/ruxc"
            chmod +x "${PREFIX}/bin/ruxc"
        fi

        if [ -d "${EXTRACT_DIR}/lib" ]; then
            cp -rf "${EXTRACT_DIR}/lib/"* "${PREFIX}/lib/" 2>/dev/null || true
        fi
    fi

    # Update shell path
    if [ "${MODIFY_PATH}" = true ]; then
        echo -e "  Configuring PATH environment..."
        update_shell_profile "${PREFIX}/bin"
    fi

    echo ""
    echo -e "${GREEN}${BOLD}Rux successfully installed!${RESET}"
    echo ""
    echo -e "To get started right away in your current terminal session, run:"
    echo -e "  ${BOLD}${CYAN}export RUX_HOME=\"${PREFIX}\"${RESET}"
    echo -e "  ${BOLD}${CYAN}export PATH=\"\$RUX_HOME/bin:\$PATH\"${RESET}"
    echo ""
    echo -e "Verify installation:"
    echo -e "  ${BOLD}rux --help${RESET}"
    echo -e "  ${BOLD}rux -e 'println(\"Hello, Rux!\");'${RESET}"
    echo ""
}

main "$@"
