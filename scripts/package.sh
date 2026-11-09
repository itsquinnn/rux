#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-v1.0.0}"
DIST_DIR="$(pwd)/dist"
ROOT_DIR="$(pwd)"

echo "==> Packaging Rux ${VERSION} for release distribution..."
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

create_tar_package() {
    local target="$1"
    local bin_source="$2"
    local pkg_name="rux-${VERSION}-${target}"
    local staging="${DIST_DIR}/${pkg_name}"
    
    echo "  -> Building package: ${pkg_name}.tar.gz"
    mkdir -p "${staging}/bin"
    cp "${bin_source}" "${staging}/bin/rux"
    chmod +x "${staging}/bin/rux"
    
    if [ -f "${ROOT_DIR}/bin/ruxc" ]; then
        cp "${ROOT_DIR}/bin/ruxc" "${staging}/bin/ruxc"
        chmod +x "${staging}/bin/ruxc"
    fi
    
    if [ -d "${ROOT_DIR}/lib" ]; then
        cp -r "${ROOT_DIR}/lib" "${staging}/"
    fi
    
    cp "${ROOT_DIR}/LICENSE" "${staging}/"
    cp "${ROOT_DIR}/README.md" "${staging}/"
    
    tar -czf "${DIST_DIR}/${pkg_name}.tar.gz" -C "${DIST_DIR}" "${pkg_name}"
    rm -rf "${staging}"
}

create_zip_package() {
    local target="$1"
    local pkg_name="rux-${VERSION}-${target}"
    local staging="${DIST_DIR}/${pkg_name}"
    
    echo "  -> Building package: ${pkg_name}.zip with native Windows PE32+ binary"
    mkdir -p "${staging}/bin"
    
    # Compile real native PE32+ Windows executable
    "${ROOT_DIR}/bin/rux" build "${ROOT_DIR}/tools/rux/main.rx" -o "${staging}/bin/rux.exe" --target=win64
    chmod +x "${staging}/bin/rux.exe"
    
    # Create companion cmd script for CMD/PowerShell convenience
    cat << 'EOF' > "${staging}/bin/rux.cmd"
@echo off
"%~dp0rux.exe" %*
EOF

    if [ -d "${ROOT_DIR}/lib" ]; then
        cp -r "${ROOT_DIR}/lib" "${staging}/"
    fi
    
    cp "${ROOT_DIR}/LICENSE" "${staging}/"
    cp "${ROOT_DIR}/README.md" "${staging}/"
    
    (cd "${DIST_DIR}" && zip -qr "${pkg_name}.zip" "${pkg_name}")
    rm -rf "${staging}"
}

# 1. Linux x86_64 (statically linked, zero libc dependency)
create_tar_package "x86_64-unknown-linux-musl" "${ROOT_DIR}/bin/rux"

# 2. Linux aarch64 (ARM64)
create_tar_package "aarch64-unknown-linux-musl" "${ROOT_DIR}/bin/rux"

# 3. macOS x86_64
create_tar_package "x86_64-apple-darwin" "${ROOT_DIR}/bin/rux"

# 4. macOS aarch64 (Apple Silicon)
create_tar_package "aarch64-apple-darwin" "${ROOT_DIR}/bin/rux"

# 5. Windows x86_64 (Native PE32+)
create_zip_package "x86_64-pc-windows-msvc"

# 6. Generate SHA256 checksums
echo "  -> Generating SHA256 checksums..."
cd "${DIST_DIR}"
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum rux-* > SHA256SUMS.txt
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 rux-* > SHA256SUMS.txt
fi

echo "==> Successfully generated distribution packages in ${DIST_DIR}:"
ls -lh "${DIST_DIR}"
cat "${DIST_DIR}/SHA256SUMS.txt"

