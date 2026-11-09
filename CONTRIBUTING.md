# Contributing to Rux

Thank you for your interest in contributing to the Rux programming language!

## Development Setup

### Prerequisites

Rux is self-hosting and requires no external compiler or linker:
- Linux (x86_64, aarch64), macOS (Intel, Apple Silicon), or Windows (x86_64).
- Standard bash environment.

### Building & Testing

1. **Verify the compiler and test suites:**
   ```bash
   ./bin/rux test
   ```

2. **Verify EIA 5-Gate Hardware Verification:**
   ```bash
   ./bin/rux verify
   ```

3. **Compile and run a program:**
   ```bash
   ./bin/rux hello.rx
   ./bin/rux build hello.rx -o hello && ./hello
   ```

## Repository Invariants

When submitting PRs or modifying the codebase, please respect the core invariants:

1. **File Length Limit:** Every `.rx` file must remain strictly under 800 lines. Factor larger modules into cleanly named helper files.
2. **Comment-Free Source Files:** `.rx` source files maintain zero code comments (`//` or `/*`). Code should be self-documenting through clean variable and function naming.
3. **No Python Dependency:** The toolchain is 100% self-hosted native code. No `.py` scripts exist or should be added to the repository.
4. **Ken Thompson Fixpoint:** The self-hosting compiler must converge to a bitwise-identical binary across successive compilation passes.
5. **Preserve Benchmark Targets:** Do not alter `hello.rx` or `me.rx`.

## Pull Request Process

1. Fork the repository and create your feature branch: `git checkout -b feature/my-feature`.
2. Ensure `./bin/rux test` and `./bin/rux verify` pass 100%.
3. Push to your branch and submit a Pull Request.

