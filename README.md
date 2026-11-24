<div align="center">

# RUX

**The Sovereign, Multi-Continuum Systems Programming Language**

[![CI](https://github.com/itsquinnn/rux/actions/workflows/ci.yml/badge.svg)](https://github.com/itsquinnn/rux/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/itsquinnn/rux?color=blue&label=release)](https://github.com/itsquinnn/rux/releases)
[![License](https://img.shields.io/badge/license-EIA--1.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Wasm-purple.svg)](docs/targets.md)
[![Zero Libc](https://img.shields.io/badge/libc-zero%20dependency-orange.svg)](README.md)

<p align="center">
  <a href="#quick-install">Quick Install</a> •
  <a href="#key-features">Features</a> •
  <a href="#syntax-tour">Syntax Tour</a> •
  <a href="#cli--toolchain">CLI Toolchain</a> •
  <a href="#cross-compilation">Cross-Compilation</a> •
  <a href="#roadmap">Roadmap</a>
</p>

</div>

---

## Overview

**Rux** is a modern, general-purpose systems programming language designed for extreme performance, memory safety, and developer expressiveness. 

Rux compiles directly to standalone native machine code without requiring external linkers, GCC, Clang, LLVM, or libc runtimes. Featuring a verified 3-pass Ken Thompson self-hosting compiler, an affine lexical ownership model (ALOR) without garbage collection, and an omni-executable continuum (Native AOT, Bytecode VM, JIT, Interpreter, and ISO C99 transpilation), Rux scales seamlessly from bare-metal kernels and embedded microcontrollers to cloud backends, game engines, and developer tools.

---

## Quick Install

Install Rux on your system with a single command (similar to Node.js, Bun, or Rust):

### Linux (`x86_64`, `aarch64`, `riscv64`) & macOS (`Intel`, `Apple Silicon`)

Install for your user (updates `~/.bashrc` / `~/.zshrc`; open a new terminal or run `source ~/.bashrc`):

```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash
```

Or install system-wide into `/usr/local/bin` (available immediately in your current terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | sudo bash
```

### Windows (PowerShell)

Install natively on Windows without needing WSL:

```powershell
irm https://raw.githubusercontent.com/itsquinnn/rux/main/install.ps1 | iex
```

### Windows (Git Bash / MSYS2 / WSL)

If you use Git Bash, MSYS2, or WSL on Windows:

```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash
```

### Precompiled Standalone Binaries

Download ready-to-run binary archives directly from [GitHub Releases](https://github.com/itsquinnn/rux/releases/latest):

| Target | Architecture | Format | Direct Latest Download |
|---|---|---|---|
| **Linux** | `x86_64` (statically linked, zero libc) | `.tar.gz` | [rux-x86_64-unknown-linux-musl.tar.gz](https://github.com/itsquinnn/rux/releases/latest/download/rux-x86_64-unknown-linux-musl.tar.gz) |
| **Linux** | `aarch64` / ARM64 | `.tar.gz` | [rux-aarch64-unknown-linux-musl.tar.gz](https://github.com/itsquinnn/rux/releases/latest/download/rux-aarch64-unknown-linux-musl.tar.gz) |
| **Linux** | `riscv64` / RISC-V 64 | `.tar.gz` | [rux-riscv64-unknown-linux-musl.tar.gz](https://github.com/itsquinnn/rux/releases/latest/download/rux-riscv64-unknown-linux-musl.tar.gz) |
| **macOS** | `Apple Silicon (M1/M2/M3/M4)` | `.tar.gz` | [rux-aarch64-apple-darwin.tar.gz](https://github.com/itsquinnn/rux/releases/latest/download/rux-aarch64-apple-darwin.tar.gz) |
| **macOS** | `x86_64 (Intel)` | `.tar.gz` | [rux-x86_64-apple-darwin.tar.gz](https://github.com/itsquinnn/rux/releases/latest/download/rux-x86_64-apple-darwin.tar.gz) |
| **Windows** | `x86_64` | `.zip` | [rux-x86_64-pc-windows-msvc.zip](https://github.com/itsquinnn/rux/releases/latest/download/rux-x86_64-pc-windows-msvc.zip) |

After installing, verify your setup:

```bash
rux --version
rux -e 'println("Hello from Rux!");'
```

---

## Key Features

- **Freestanding & Zero-Dependency** — Emits direct-syscall native binaries with no libc, CRT, or external linker required.
- **3-Pass Ken Thompson Self-Hosting** — The compiler is written in Rux and converges to bitwise-identical output across successive compilation passes (`cmp -s stage2 stage3`).
- **Memory Safety by Construction** — Affine Lexical Ownership (ALOR) guarantees deterministic cleanup at compile-time without a garbage collector or runtime overhead.
- **Cross-Platform Native Codegen** — Direct machine-code emission for ELF64 (Linux), PE32+ (Windows), Mach-O (macOS), and WebAssembly (Wasm MVP).
- **Multi-Execution Continuum** — Run code the way you need:
  - `rux <file.rx>` — Instant native execution.
  - `rux build <file.rx> -o bin` — Ahead-of-time standalone binary compilation.
  - `rux jit <file.rx>` — In-memory native machine-code JIT compilation.
  - `rux vm <file.rx>` — High-throughput bytecode virtual machine.
  - `rux interp <file.rx>` — Direct AST interpreter.
  - `rux transpile <file.rx>` — Portable ISO C99 emission.
- **Comprehensive Standard Library** — High-performance collections (`Vec`, `HashMap`, `BTreeMap`, `HashSet`, `LinkedList`, `BinaryHeap`), native UTF-8 strings, cryptographic primitives (BLAKE3), and system I/O.

---

## Syntax Tour

### Hello World & Functions

```rx
fn greet(name: str) {
    println("Hello, " + name + "!");
}

fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() -> i32 {
    greet("World");
    let sum = add(40, 2);
    println("Result: " + sum.to_str());
    return 0;
}
```

### Expression-Based Control Flow & Loops with Values

```rx
let age = 21;
let category = if age >= 18 { "Adult" } else { "Minor" };

var counter = 0;
let final_value = loop {
    counter = counter + 1;
    if counter == 10 {
        break counter * 2;
    }
};
```

### Exhaustive Pattern Matching & Match Guards

```rx
fn classify_status(code: i32) -> str {
    match code {
        200 => "OK",
        201 | 204 => "Success",
        x if x >= 400 && x < 500 => "Client Error",
        500..=599 => "Server Error",
        _ => "Unknown Status",
    }
}
```

### Standard Collections & Iterators

```rx
var numbers = vec[10, 20, 30, 40, 50];
numbers.push(60);

var map = HashMap.new();
map.insert("port", 8080);
map.insert("max_connections", 1024);

for item in numbers {
    println("Value: " + item.to_str());
}
```

---

## CLI & Toolchain

```bash
# Execute a Rux source file directly
rux app.rx

# Compile to a standalone native binary
rux build app.rx -o app
./app

# Evaluate inline expressions
rux -e 'println(10 * 4 + 2);'

# Launch interactive REPL session
rux repl

# Run on the bytecode VM or native JIT
rux vm app.rx
rux jit app.rx

# Transpile to portable ISO C99
rux transpile app.rx -o app.c

# Run the master test harness & hardware verification ring
rux test
rux verify
rux eia

# Validate EIA hologram integrity, cross-unit contracts, relink, and run via IP-HEE loader
rux eia-check ./app
rux eia-link-check ./client ./provider
rux eia-relink ./client ./provider -o ./relinked
rux eia-run ./app
```

---

## Cross-Compilation

Compile for any target architecture without installing secondary toolchains:

```bash
# Compile for Linux ARM64 (aarch64) or RISC-V 64
rux build main.rx -o main_arm64 --target=arm64
rux build main.rx -o main_rv64 --target=riscv64

# Compile for Windows x86-64 (.exe)
rux build main.rx -o main.exe --target=win64

# Compile for macOS (Apple Silicon arm64 or Intel x86_64)
rux build main.rx -o main_mac_arm64 --target=macos-arm64
rux build main.rx -o main_mac_x64 --target=macos

# Compile for WebAssembly (WASI)
rux build main.rx -o main.wasm --wasm
```

---

## Master Specification & Roadmap

Rux is developed according to the authoritative **Rux Master Language Specification**:

| Milestone | Area | Status |
|---|---|---|
| **Step 1** (Decisions 1–62) | Variables, Declarations & Mutability | Completed (100% Verified) |
| **Step 2** (Decisions 63–160) | Type System, Pointers & Low-Level Semantics | Completed (100% Verified) |
| **Step 3** (Decisions 161–190) | Functions, Inherent Methods & Overloading | Completed (100% Verified) |
| **Step 4** (Decisions 191–200) | Control Flow, Loops with Values & Pattern Matching | Completed (100% Verified) |
| **Step 5** (Decisions 201–210) | Collections (`Vec`, `HashMap`, `Heap`), Strings & Box | Completed (100% Verified) |
| **Step 6** (Decisions 211–220) | Modules, Multi-File Imports & Namespaces (`mod`/`use`) | Core Support Verified (`test_steps6_to_10_and_ergonomics.rx`) |
| **Step 7** (Decisions 221–230) | Unified Error Handling (`Result<T, E>`, `Option`, `ensure`) | Core Support Verified (`test_steps6_to_10_and_ergonomics.rx`) |
| **Step 8** (Decisions 231–240) | Structured Concurrency, Fibers & Async/Await | In Progress (Async/Concurrent Substrate Tests) |
| **Step 9** (Decisions 241–250) | FFI (`extern "C"`), `extern` Contracts & OS Syscalls | Core Support & EIA Import Contracts Verified |
| **Step 10** (Decisions 251–260)| Generics, Lambdas, Pythonic Ergonomics (`def`/`say`/`vec`/`map`) | Core Support Verified (`test_steps6_to_10_and_ergonomics.rx`) |
| **Ecosystem** | Central Package Registry & Web Frameworks | Planned |

### Eternal Interface Architecture (EIA) & Platform Boundaries

Rux binaries embed a 96-byte **`UniversalHologramHeader`** (`magic = 0x4849457F`, versioned via `abi_epoch = (major << 16) | minor`) across ELF64/freestanding/`-c`/`-shared`/UPBP, static `.a` archives (ELF64 & Mach-O members, GNU `/0`/`/16` longnames), PE32+/UEFI (`.eia`), Mach-O (`__EIA`), and Wasm (`"eia"` custom sections). Each hologram indexes **`SymbolContract[]`** (`"EIA_SIG2"` domain-separated signature hashing with `ret_is_ptr`), **`EiaTypeGraphEntry[]`**, and **`EiaRelocHole[]`** (`DISP32`, `CALL32`, `LEA32`, and `WIDEN_STENCIL` for wide `>= 128`-byte field offsets) sealed by an **unkeyed 64-bit BLAKE3 integrity digest** (`blake3_root` via `"EIAMV2\0\0"`/`"EIAROOT1"`, folding tables, headers/sections, executable code, and immutable/data sections via `EIA_FLAG_HAS_CODE_HASH`).

- `rux eia-check <binary|archive.a>` validates hologram tables, ELF/Mach-O `.a` members, major `abi_epoch` (`-9`), and BLAKE3 integrity (`-3` on tampering).
- `rux eia-link-check <client> <provider1> [provider2 ...]` verifies cross-unit symbol/signature/calling-convention contracts, transitive imports (including `.a` members), and `abi_epoch` major compatibility (`-9`).
- `rux eia-relink <client> <provider1> [provider2 ...] -o <out>` performs **offline** post-ABI layout relinking across `x86_64`, `ARM64`, `RISC-V`, PE32+, and Mach-O with branch-range/span validation, and splices compatible provider code/rodata sections (`ELF64`/multi-member `.a` `.text`, PE32+ `.pcode`, Mach-O `__PCODE`) for `extern fn` (`EIA_SYM_IMPORT`) imports with unified multi-section BLAKE3 sealing.
- `rux eia-run <binary>` verifies hologram integrity, epoch, imports, and host `x86_64` ELF64/UPBP constraints fail-closed (`-2`/`-3`/`-5`/`-7`/`-9`) before in-process IP-HEE execution.
- `rux verify` / `rux eia` run the **5-Gate Hardware Verification Ring** (1: Direct Silicon Syscall Bridge, 2: Memory Arena & 64-Byte Cacheline Invariant, 3: Universal Hologram/Contracts/Relocs/BLAKE3, 4: RXD Vitrification & Units, 5: Self-Hosting Binary & Embedded Hologram) and end-to-end EIA proofs.

**Explicit scope boundaries**: `blake3_root` provides unkeyed 64-bit integrity verification (detecting corruption/tampering, not cryptographic authorship against adversarial re-sealing); `eia-relink` is an offline binary/archive relinker (not a runtime `ld.so` dynamic loader); and EIA operates **on top of** required OS container formats, CPU calling conventions, OS syscalls, and C FFI ABIs. Target `--wasm` emits WASI `fd_write` + `_start` (alongside exported `main`) and `"eia"` custom sections. See [`docs/eia-spec.md`](docs/eia-spec.md) for the binary layout, contract, relinking, and verification specification.

---

## Building from Source

```bash
# Clone the repository
git clone https://github.com/itsquinnn/rux.git
cd rux

# Verify test suite (all 10 sovereign test suites)
./bin/rux test

# Verify hardware verification ring (5 EIA gates)
./bin/rux verify

# Install locally
./install.sh --local
```

---

## Contributing

We welcome contributions! Please review [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`SECURITY.md`](.github/SECURITY.md) before opening a pull request.

---

## License

This project is licensed under the **Eternal Interface Architecture (EIA) License**. See [`LICENSE`](LICENSE) for terms.

Copyright (c) 2026 Qumi Technologies Pvt Ltd. All rights reserved.
