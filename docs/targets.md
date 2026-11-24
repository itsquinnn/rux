# Supported Targets

Rux compiles to multiple platforms and output formats from a single source.

## Target Triples

| Target | Architecture | Format | Description |
|--------|-------------|--------|-------------|
| `linux` / `x86_64` / `x86_64-linux` | x86-64 | ELF64 | Linux desktop/server |
| `arm64` / `linux-arm64` / `android` / `android-arm64` | ARM64 | ELF64 | Linux / Android ARM64 |
| `arm64-baremetal` | ARM64 | ELF64 | Bare-metal ARM64 ELF64 |
| `riscv64` / `linux-riscv64` | RISC-V | ELF64 | RISC-V Linux |
| `win64` / `windows` / `x86_64-windows` | x86-64 | PE32+ | Windows |
| `macos` / `darwin` / `macos-x64` / `x86_64-macos` | x86-64 | Mach-O 64 | macOS Intel |
| `macos-arm64` / `arm64-macos` / `darwin-arm64` / `arm64-darwin` / `apple-silicon` / `ios` / `ios-arm64` | ARM64 | Mach-O 64 | macOS Apple Silicon / iOS |
| `uefi` | x86-64 | PE32+ | UEFI firmware (`--format=uefi` / `--uefi`) |
| `baremetal` / `multiboot` | x86-64 | ELF64 | Bare metal / multiboot (`format_kind = 0`) |
| `opensbi` | RISC-V | ELF64 | OpenSBI (`format_kind = 0`) |
| `wasm` / `wasm32` / `wasm64` | WASM | .wasm | WebAssembly MVP + WASI + `"eia"` section |

Both `-target <t>` and `--target=<t>` are supported (unknown target/format names exit non-zero). Use `-c` for `ET_REL` (`.o`) and `-shared` for `ET_DYN` (`.so`).

## Output Formats

| Format | Flag | Description |
|--------|------|-------------|
| ELF64 | `--elf` / `--format=elf` | Standard Linux executable (`-c` for `.o`, `-shared` for `.so`) |
| PE32+ | `--pe` / `--format=pe` / `--format=coff` | Windows executable |
| Mach-O 64 | `--macho` / `--format=macho` | macOS executable |
| UPBP | `--upbp` / `--format=upbp` | Universal Polyglot Binary (MZ + ELF + PE + Mach-O in one file) |
| Freestanding | `--freestanding` | Direct-syscall ELF without section headers, sealed with `EIA_FLAG_FREESTANDING` |
| WASM | `--wasm` / `--format=wasm` | WebAssembly module |

> [!NOTE]
> Host `rux eia-run` executes host `x86_64` ELF64/UPBP binaries directly and fails closed on `.a` archives, `ET_REL` (`.o`), and non-`x86_64` artifacts (`-2`/`-3`). Target-specific codegen intrinsics (such as x86-only fallback `sys_exit` generation in `runtime_guard.rx`) require `target_arch == 0`.

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
