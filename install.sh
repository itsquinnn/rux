#!/usr/bin/env bash
set -euo pipefail

# Rux Multi-Platform Universal Installer
# Compatible with Linux (x86_64, aarch64, riscv64), macOS (Intel, Apple Silicon),
# and Windows (Git Bash / MSYS2 / Cygwin / WSL).

REPO="itsquinnn/rux"
VERSION="${RUX_VERSION:-latest}"
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
  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash -s -- [options]
  ./install.sh [options]

Options:
  --prefix <path>     Install to custom directory (default: ~/.rux)
  --version <ver>     Install specific release tag or 'latest' (default: ${VERSION})
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

    IS_WINDOWS=false
    IS_MACOS=false
    ARCHIVE_EXT="tar.gz"

    case "${os}" in
        Linux)
            OS_TARGET="unknown-linux-musl"
            ;;
        Darwin)
            OS_TARGET="apple-darwin"
            IS_MACOS=true
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS_TARGET="pc-windows-msvc"
            IS_WINDOWS=true
            ARCHIVE_EXT="zip"
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
        riscv64)
            ARCH_TARGET="riscv64"
            ;;
        *)
            echo -e "${RED}Unsupported processor architecture: ${arch}${RESET}" >&2
            exit 1
            ;;
    esac

    if [ "${IS_WINDOWS}" = true ] && [ "${ARCH_TARGET}" != "x86_64" ]; then
        echo -e "${RED}Windows native binaries currently target x86_64 (detected ${arch}).${RESET}" >&2
        exit 1
    fi

    if [ "${IS_MACOS}" = true ] && [ "${ARCH_TARGET}" = "riscv64" ]; then
        echo -e "${RED}Unsupported architecture for macOS: ${arch}${RESET}" >&2
        exit 1
    fi

    PLATFORM="${ARCH_TARGET}-${OS_TARGET}"
}

download_file() {
    local url="$1"
    local dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${url}" -o "${dest}"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${dest}" "${url}"
    else
        echo -e "${RED}Error: curl or wget is required to download Rux.${RESET}" >&2
        exit 1
    fi
}

update_shell_profile() {
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
                local fish_cfg="$HOME/.config/fish/config.fish"
                mkdir -p "$(dirname "${fish_cfg}")"
                if ! grep -q "RUX_HOME" "${fish_cfg}" 2>/dev/null; then
                    {
                        echo ""
                        echo "# Rux Programming Language Environment"
                        echo "set -gx RUX_HOME \"${PREFIX}\""
                        echo 'fish_add_path "$RUX_HOME/bin"'
                    } >> "${fish_cfg}"
                    echo -e "  ${GREEN}✓${RESET} Updated ${CYAN}${fish_cfg}${RESET}"
                fi
                return
                ;;
        esac
    fi

    # Fallbacks
    shell_configs+=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")

    local path_line="export RUX_HOME=\"${PREFIX}\""
    local env_line='export PATH="$RUX_HOME/bin:$PATH"'
    local updated=false

    for cfg in "${shell_configs[@]}"; do
        if [ -f "${cfg}" ]; then
            if ! grep -q "RUX_HOME" "${cfg}" 2>/dev/null; then
                {
                    echo ""
                    echo "# Rux Programming Language Environment"
                    echo "${path_line}"
                    echo "${env_line}"
                } >> "${cfg}"
                echo -e "  ${GREEN}✓${RESET} Updated ${CYAN}${cfg}${RESET}"
            fi
            updated=true
            break
        fi
    done

    if [ "${updated}" = false ]; then
        {
            echo ""
            echo "# Rux Programming Language Environment"
            echo "${path_line}"
            echo "${env_line}"
        } >> "$HOME/.profile"
        echo -e "  ${GREEN}✓${RESET} Configured ${CYAN}$HOME/.profile${RESET}"
    fi
}

install_from_dir() {
    local src_root="$1"
    if [ "${IS_WINDOWS}" = true ]; then
        cp -f "${src_root}/bin/rux.exe" "${PREFIX}/bin/rux.exe"
        chmod +x "${PREFIX}/bin/rux.exe"
        if [ -f "${src_root}/bin/ruxc.exe" ]; then
            cp -f "${src_root}/bin/ruxc.exe" "${PREFIX}/bin/ruxc.exe"
            chmod +x "${PREFIX}/bin/ruxc.exe"
        fi
        cat << 'EOF' > "${PREFIX}/bin/rux.cmd"
@echo off
"%~dp0rux.exe" %*
EOF
        cat << 'EOF' > "${PREFIX}/bin/rux"
#!/usr/bin/env bash
exec "$(dirname "$0")/rux.exe" "$@"
EOF
        chmod +x "${PREFIX}/bin/rux"
    else
        cp -f "${src_root}/bin/rux" "${PREFIX}/bin/rux"
        chmod +x "${PREFIX}/bin/rux"
        if [ -f "${src_root}/bin/ruxc" ]; then
            cp -f "${src_root}/bin/ruxc" "${PREFIX}/bin/ruxc"
            chmod +x "${PREFIX}/bin/ruxc"
        fi
    fi

    if [ -d "${src_root}/lib" ]; then
        cp -rf "${src_root}/lib/"* "${PREFIX}/lib/" 2>/dev/null || true
    fi
}

main() {
    print_banner
    detect_platform

    echo -e "${BOLD}Installing Rux (${CYAN}${VERSION}${RESET}${BOLD}) for ${GREEN}${PLATFORM}${RESET}${BOLD}...${RESET}"
    echo -e "  Target directory: ${CYAN}${PREFIX}${RESET}"

    mkdir -p "${PREFIX}/bin"
    mkdir -p "${PREFIX}/lib"

    if [ "${LOCAL_MODE}" = true ] || { [ "${IS_WINDOWS}" = false ] && [ -f "./bin/rux" ]; } || { [ "${IS_WINDOWS}" = true ] && [ -f "./bin/rux.exe" ]; }; then
        echo -e "  Installing from local repository..."
        install_from_dir "."
    else
        echo -e "  Downloading package from GitHub Releases..."
        if [ "${VERSION}" = "latest" ]; then
            ARCHIVE_NAME="rux-${PLATFORM}.${ARCHIVE_EXT}"
            DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ARCHIVE_NAME}"
        else
            ARCHIVE_NAME="rux-${VERSION}-${PLATFORM}.${ARCHIVE_EXT}"
            DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"
        fi

        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "${TMP_DIR}"' EXIT

        download_file "${DOWNLOAD_URL}" "${TMP_DIR}/${ARCHIVE_NAME}"

        if [ "${ARCHIVE_EXT}" = "zip" ]; then
            if command -v unzip >/dev/null 2>&1; then
                unzip -qo "${TMP_DIR}/${ARCHIVE_NAME}" -d "${TMP_DIR}/extract"
            elif command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -NoProfile -Command "Expand-Archive -Path '${TMP_DIR}/${ARCHIVE_NAME}' -DestinationPath '${TMP_DIR}/extract' -Force"
            else
                echo -e "${RED}Error: unzip or powershell.exe is required to extract Windows zip archives.${RESET}" >&2
                exit 1
            fi
        else
            mkdir -p "${TMP_DIR}/extract"
            tar -xzf "${TMP_DIR}/${ARCHIVE_NAME}" -C "${TMP_DIR}/extract"
        fi

        BIN_DIR_FOUND="$(find "${TMP_DIR}/extract" -maxdepth 3 -type d -name bin | head -n 1)"
        if [ -z "${BIN_DIR_FOUND}" ]; then
            echo -e "${RED}Error: Extracted archive did not contain a bin/ directory.${RESET}" >&2
            exit 1
        fi
        EXTRACT_DIR="$(dirname "${BIN_DIR_FOUND}")"
        install_from_dir "${EXTRACT_DIR}"
    fi

    # Strip macOS quarantine xattr without modifying Mach-O / EIA bytes
    if [ "${IS_MACOS}" = true ] && command -v xattr >/dev/null 2>&1; then
        xattr -cr "${PREFIX}" 2>/dev/null || true
    fi

    # Update shell path
    if [ "${MODIFY_PATH}" = true ]; then
        echo -e "  Configuring PATH environment..."
        update_shell_profile
    fi

    echo ""
    echo -e "${GREEN}${BOLD}Rux successfully installed!${RESET}"
    if "${PREFIX}/bin/rux" --version >/dev/null 2>&1; then
        echo -e "  Version: ${CYAN}$("${PREFIX}/bin/rux" --version)${RESET}"
    fi
    echo ""
    echo -e "To get started right away in your current terminal session, run:"
    echo -e "  ${BOLD}${CYAN}export RUX_HOME=\"${PREFIX}\"${RESET}"
    echo -e "  ${BOLD}${CYAN}export PATH=\"\$RUX_HOME/bin:\$PATH\"${RESET}"
    echo ""
    echo -e "Verify installation:"
    echo -e "  ${BOLD}rux --version${RESET}"
    echo -e "  ${BOLD}rux -e 'println(\"Hello, Rux!\");'${RESET}"
    echo ""
}

main "$@"
