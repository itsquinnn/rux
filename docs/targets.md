# Supported Targets

Rux compiles to multiple platforms and output formats from a single source.

## Target Triples

| Target | Architecture | Format | Description |
|--------|-------------|--------|-------------|
| `linux` / `x86_64` | x86-64 | ELF64 | Linux desktop/server |
| `arm64` / `linux-arm64` | ARM64 | ELF64 | Linux ARM64 |
| `riscv64` | RISC-V | ELF64 | RISC-V Linux |
| `win64` / `windows` | x86-64 | PE32+ | Windows |
| `macos` / `darwin` | x86-64 | Mach-O 64 | macOS Intel |
| `macos-arm64` / `darwin-arm64` | ARM64 | Mach-O 64 | macOS Apple Silicon |
| `ios` / `ios-arm64` | ARM64 | Mach-O 64 | iOS |
| `android` / `android-arm64` | ARM64 | ELF64 | Android |
| `uefi` | x86-64 / ARM64 | PE32+ | UEFI firmware |
| `baremetal` / `multiboot` | x86-64 / ARM64 | Raw ELF | Bare metal / bootloader |
| `opensbi` | RISC-V | Raw binary | OpenSBI |
| `wasm` / `wasm32` / `wasm64` | WASM | .wasm | WebAssembly MVP |

## Output Formats

| Format | Flag | Description |
|--------|------|-------------|
| ELF64 | `--elf` (default for Linux) | Standard Linux executable |
| PE32+ | `--pe` | Windows executable |
| Mach-O 64 | `--macho` | macOS executable |
| UPBP | `--upbp` | Universal Polyglot Binary (MZ + ELF + PE + Mach-O in one file) |
| Freestanding | `--freestanding` | ~174-byte direct-syscall ELF, no libc/linker |
| WASM | `--wasm` | WebAssembly module |

## Examples

```bash
# Default: Linux ELF64
rux build app.rx -o app

# Windows executable
rux build app.rx --target=win64 -o app.exe

# macOS universal
rux build app.rx --target=macos -o app
rux build app.rx --target=macos-arm64 -o app-arm64

# iOS (Mach-O arm64)
rux build app.rx --target=ios -o app

# Android (ARM64 ELF)
rux build app.rx --target=android -o app

# WebAssembly
rux build app.rx --target=wasm -o app.wasm

# UEFI bootable
rux build app.rx --target=uefi -o app.efi

# Bare-metal multiboot
rux build app.rx --target=baremetal -o kernel.bin

# Freestanding minimal binary
rux build app.rx --target=baremetal --freestanding -o app

# Polyglot binary (runs on Linux, Windows, macOS)
rux build app.rx --upbp -o app
```

## Target Detection

Output format can also be inferred from the file extension:
- `.exe` → PE32+ (Windows)
- `.macho` / `.dylib` → Mach-O 64 (macOS)
- `.efi` → PE32+ (UEFI)
- `.wasm` → WebAssembly
- `.elf` → ELF64 (Linux)
