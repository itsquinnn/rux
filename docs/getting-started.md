# Getting Started with Rux

Rux is a self-hosting systems programming language that compiles to standalone native binaries
without external linkers or libc dependencies. It targets Linux (`x86_64`, `aarch64`, `riscv64`),
Windows (`x86_64`), macOS (`Intel`, `Apple Silicon`), WebAssembly (WASI), UEFI, and bare metal
from a single codebase.

## Quick Install

### Linux & macOS
```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/itsquinnn/rux/main/install.ps1 | iex
```

### Windows (Git Bash / MSYS2 / WSL)
```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash
```

Verify your installation:
```bash
rux --version
rux -e 'println("Hello, Rux!");'
```

## Build from Source

```bash
git clone https://github.com/itsquinnn/rux.git
cd rux

# Verify self-hosting compiler and test suites
./bin/rux --version
./bin/rux test
./bin/rux verify
./bin/rux eia

# Install locally to ~/.rux
./install.sh --local
```

## Hello World

Create `hello.rx`:

```rx
fn main() -> int {
    println("Hello, Rux!");
    return 0;
}
```

Compile and run:

```bash
rux build hello.rx -o hello
./hello
```

Or compile and execute immediately:

```bash
rux run hello.rx
```

## Cross-Compile

```bash
# Linux x86_64 / ARM64 / RISC-V 64
rux build hello.rx -o hello
rux build hello.rx --target=arm64 -o hello_arm64
rux build hello.rx --target=riscv64 -o hello_rv64

# Windows PE32+ (.exe)
rux build hello.rx --target=win64 -o hello.exe

# macOS Mach-O (Apple Silicon & Intel, ad-hoc signed)
rux build hello.rx --target=macos-arm64 -o hello_mac_arm64
rux build hello.rx --target=macos -o hello_mac_x64

# WebAssembly (WASI)
rux build hello.rx --wasm -o hello.wasm

# UEFI & Freestanding bare-metal
rux build hello.rx --target=uefi -o hello.efi
rux build hello.rx --target=baremetal --freestanding -o hello_bare
```

## Next Steps

- Read the [Language Specification](./language-spec.md)
- Review [Supported Targets](./targets.md)
- Browse the [Standard Library](./stdlib.md)
- Check the [CLI Reference](./cli.md)
- Explore the [EIA Specification](./eia-spec.md)
