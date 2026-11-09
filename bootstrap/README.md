# Sovereign Bootstrap Architecture (`bootstrap/`)

## 1. Overview & Human Design Philosophy

This folder contains the complete, self-hosting bootstrap pipeline for the `rux` language. 

Unlike legacy monolithic compilers that bundle thousands of lines of unreadable code into a single fragile file, our bootstrap architecture is **cleanly split into modular, single-responsibility files (50–120 lines each)** named with **plain programming English words**.

Every file is structured so any developer can immediately understand:
1. **WHY** the file exists.
2. **WHAT** it does.
3. **HOW** to edit it or add new features without breaking unrelated parts of the system.

---

## 2. Directory & Module Organization

```text
bootstrap/
├── boot_config.rxd          # Sovereign boot configuration in .rxd format
├── README.md                # This human architecture guide
│
├── stage0/                  # Stage-0 Cold-Start Seed
│   ├── stage0_seed.rx       # Stage-0 bootstrap seed compiler driver
│   ├── bootstrap_host.rx    # Zero-dependency native host bootstrap builder
│   └── README.md            # Stage-0 execution guide
│
├── stage1/                  # Stage-1 Self-Hosting Compiler
│   ├── stage1_entry.rx      # Stage-1 compiler runner producing Stage-2 & 3
│   └── README.md            # Fixpoint convergence gate guide
│
├── memory/                  # Memory Management
│   ├── allocator.rx         # Fast 1-cycle monotonic bump memory arena
│   └── buffer.rx            # Raw byte copy, fill, and equality comparisons
│
├── scanner/                 # Lexical Analysis & Tokenization
│   ├── tokens.rx            # Token kind constants and Token data structure
│   ├── keywords.rx          # O(1) keyword classification table (int, uint, fn, let...)
│   └── reader.rx            # Source character reader, whitespace & comment skipper
│
├── syntax/                  # Grammar & AST Parsing
│   ├── ast.rx               # Abstract Syntax Tree node kinds and structures
│   ├── expressions.rx       # Expression parser (binary operators, pipes `|>`)
│   ├── statements.rx        # Statement parser (let/mut, return, println, ASI)
│   ├── shapes.rx            # Shape and struct declaration parser & field layout
│   └── parser.rx            # Master parser coordinating functions and programs
│
├── types/                   # Canonical Type System
│   ├── primitives.rx        # Canonical BLAKE3-64 hashes for natural types (int, uint, byte...)
│   └── checker.rx           # Type compatibility and safe widening verification
│
├── emitter/                 # Machine Code Generation
│   ├── instructions.rx      # Byte and word stream emitters
│   ├── stencils.rx          # Pre-computed machine instruction templates (PCMSS)
│   └── codegen.rx           # AST to machine instruction compiler
│
├── binary/                  # Executable Vessel Packaging
│   ├── elf.rx               # 64-bit ELF header and program header definitions
│   └── writer.rx            # Direct syscall executable file writer (0755 permissions)
│
├── verifier/                # Self-Hosting Fixpoint Gate
│   ├── hash_check.rx        # File checksum accumulator and byte-for-byte comparator
│   └── three_pass.rx        # Ken Thompson 3-Pass fixpoint verification gate
│
├── rxd/                     # Bootstrap RXD Dual-Continuum Data Subsystem
│   ├── reader.rx            # Zero-allocation bootstrap .rxdb plate loader
│   ├── vitrifier.rx         # Minimal bootstrap .rxd -> .rxdb vitrification compiler
│   └── config.rx            # Loads boot_config.rxdb into BootstrapConfig
│
└── driver/                  # Master Orchestration
    ├── compiler.rx          # Single-call compiler pipeline API (`compile_source_file`)
    └── bootstrap.rx         # 3-Pass self-hosting bootstrap runner
```

---

## 3. How a Human Developer Edits This Codebase

| Task | File to Edit | Instructions |
| :--- | :--- | :--- |
| **Add a new keyword** (e.g. `defer`) | [`scanner/keywords.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/scanner/keywords.rx) | Add the token constant in `tokens.rx` and the FNV-1a hash in `classify_keyword`. |
| **Add an operator** (e.g. `^` or `==`) | [`syntax/expressions.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/syntax/expressions.rx) | Add the operator precedence rule in `parse_expression`. |
| **Add a new statement** (e.g. `match`) | [`syntax/statements.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/syntax/statements.rx) | Add the statement handler in `parse_statement`. |
| **Add a machine stencil** (e.g. SIMD FMA) | [`emitter/stencils.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/emitter/stencils.rx) | Define the opcode bytes in `stencil_bank_init`. |
| **Adjust compiler memory limits** | [`driver/compiler.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/driver/compiler.rx) | Adjust the `arena_buffer` capacity. |

---

## 4. The Ken Thompson 3-Pass Fixpoint Verification

In Ken Thompson's classic Turing Award lecture (*"Reflections on Trusting Trust"*), he proved that a compiler is only genuinely self-hosting and deterministic when it compiles itself across 3 passes to achieve a **fixed point**:

```text
Pass 1:  Stage-0 (Seed)     ──compiles compiler.rx──>  Stage-1 Binary
Pass 2:  Stage-1 Binary     ──compiles compiler.rx──>  Stage-2 Binary
Pass 3:  Stage-2 Binary     ──compiles compiler.rx──>  Stage-3 Binary
Gate:    ASSERT: hash(Stage-2) == hash(Stage-3) [Bitwise 100% Identical]
```

- When **Stage-2 == Stage-3**, the compiler has converged to a **Fixed Point**.
- This mathematically guarantees zero compiler mutation, zero undefined behavior leakage, and absolute reproducibility.
- Implemented in [`verifier/three_pass.rx`](file:///home/bishwaxyz/ru/rux/src/bootstrap/verifier/three_pass.rx).
