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

### Linux & macOS (Intel & Apple Silicon)

```bash
curl -fsSL https://raw.githubusercontent.com/itsquinnn/rux/main/install.sh | bash
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

| Target | Architecture | Format | Download |
|---|---|---|---|
| **Linux** | `x86_64` (statically linked, zero libc) | `.tar.gz` | [Download](https://github.com/itsquinnn/rux/releases/latest) |
| **Linux** | `aarch64` / ARM64 | `.tar.gz` | [Download](https://github.com/itsquinnn/rux/releases/latest) |
| **macOS** | `Apple Silicon (M1/M2/M3/M4)` | `.tar.gz` | [Download](https://github.com/itsquinnn/rux/releases/latest) |
| **macOS** | `x86_64 (Intel)` | `.tar.gz` | [Download](https://github.com/itsquinnn/rux/releases/latest) |
| **Windows** | `x86_64` | `.zip` | [Download](https://github.com/itsquinnn/rux/releases/latest) |

After installing, verify your setup:

```bash
rux --help
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
```

---

## Cross-Compilation

Compile for any target architecture without installing secondary toolchains:

```bash
# Compile for Linux ARM64 (aarch64)
rux build main.rx -o main_arm64 --target=arm64

# Compile for Windows x86-64 (.exe)
rux build main.rx -o main.exe --target=win64

# Compile for macOS (Mach-O 64-bit)
rux build main.rx -o main_macos --target=macos

# Compile for WebAssembly
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
| **Step 6** (Decisions 211–220) | Modules, Multi-File Imports & Namespaces | *In Progress* |
| **Step 7** (Decisions 221–230) | Unified Error Handling (`Result<T, E>`, `Option`, `?`) | Up Next |
| **Step 8** (Decisions 231–240) | Structured Concurrency, Fibers & Async/Await | Planned |
| **Step 9** (Decisions 241–250) | FFI (`extern "C"`), Dynamic Linking & OS Syscalls | Planned |
| **Step 10** (Decisions 251–260)| Metaprogramming, Hygienic Macros & Reflection | Planned |
| **Ecosystem** | Central Package Registry & Web Frameworks | Planned |

---

## Building from Source

```bash
# Clone the repository
git clone https://github.com/itsquinnn/rux.git
cd ru

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
