# Stage-0 Bootstrap Seed Architecture (`rux/src/bootstrap/stage0/`)

## 1. Purpose & Role in the 3-Pass Fixpoint

In Ken Thompson's Turing Award theorem on compiler verification, every self-hosting language requires a **trusted seed** (Stage-0) to break the circular dependency of compiling a compiler with itself.

```text
Host Environment (Linux / Python 3 / C)
       │
       ▼
Pass 1: Stage-0 (Seed)     ──compiles compiler.rx──>  Stage-1 Binary
Pass 2: Stage-1 Binary     ──compiles compiler.rx──>  Stage-2 Binary
Pass 3: Stage-2 Binary     ──compiles compiler.rx──>  Stage-3 Binary
Gate:   ASSERT: hash(Stage-2) == hash(Stage-3) [Bitwise 100% Identical]
```

## 2. Files in this Directory

- [`stage0_seed.rx`](file:///home/bishwaxyz/ru/bootstrap/stage0/stage0_seed.rx): Rux source entrypoint that drives Stage-0 compilation of the compiler into `build_stages/stage1_bin`.
- [`bootstrap_host.rx`](file:///home/bishwaxyz/ru/bootstrap/stage0/bootstrap_host.rx): Zero-dependency native host bootstrap builder. Generates the freestanding ELF64 seed without any external Python or C compiler.

## 3. How to Execute Stage-0 Bootstrap

To compile and execute the Stage-0 bootstrap:
```bash
./bin/rux bootstrap/stage0/bootstrap_host.rx -o bin/bootstrap_host
./bin/bootstrap_host bootstrap/stage0/stage0_seed.rx build_stages/stage0_bin
./build_stages/stage0_bin
```
