# Getting Started with Rux

Rux is a self-hosting systems programming language that compiles to native binaries
without external linkers. It targets Linux, Windows, macOS, Android, iOS, WebAssembly,
UEFI, and bare metal from a single codebase.

## Install

Rux is self-hosting. Bootstrap the compiler from source:

```bash
# Clone the repository
git clone <rux-repo>
cd ru

# Run the Stage-0 bootstrap seed (requires Python 3)
python3 bootstrap/stage0/bootstrap_host.rx bootstrap/stage0/stage0_seed.rx build_stages/stage0_bin

# Run Stage-0 to build Stage-1
./build_stages/stage0_bin

# The compiler is now at bin/rux
./bin/rux --version
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
./bin/rux build hello.rx -o hello
./hello
```

Or compile and execute immediately:

```bash
./bin/rux run hello.rx
```

## Cross-Compile

```bash
# Linux x86_64 (default)
./bin/rux build hello.rx -o hello

# Windows PE32+
./bin/rux build hello.rx --target=win64 -o hello.exe

# macOS Mach-O
./bin/rux build hello.rx --target=macos -o hello

# Android (ARM64 ELF)
./bin/rux build hello.rx --target=android -o hello

# iOS (ARM64 Mach-O)
./bin/rux build hello.rx --target=ios -o hello

# WebAssembly
./bin/rux build hello.rx --target=wasm -o hello.wasm

# UEFI
./bin/rux build hello.rx --target=uefi -o hello.efi

# Freestanding bare-metal (~174 byte ELF)
./bin/rux build hello.rx --target=baremetal --freestanding -o hello
```

## Next Steps

- Read the [Language Specification](./language-spec.md)
- Browse the [Standard Library](./stdlib.md)
- Check the [CLI Reference](./cli.md)
