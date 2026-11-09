# Rux Sovereign Compiler Architecture

This document defines the structural layout and engineering principles of the Rux compiler ([`rux/compiler/`](file:///home/bishwaxyz/ru/rux/compiler/)).

The compiler is organized into the **13 Sovereign Subsystems**:

```text
compiler/
├── rux.rx                 # Unified self-hosting compiler entrypoint
├── verify_5gate.rx        # EIA 5-Gate hardware verification ring
├── rsc/                   # Rux Source Code: lexer, ast, parser, optimizer, codegen, writers
├── pipeline/              # Master Compiler Pipeline: Driver, Options, Diagnostics, Pipeline
└── subsystems/            # 13 Sovereign Architectural Subsystems
    ├── eia/               # Eternal Interface Architecture: Universal Hologram, Contracts, Relocations
    ├── saes/              # Sovereign Autonomic Executive: DVAM Memory Aliasing, SRT Patcher
    ├── zwns/              # Zero-Waste Native Synthesis: PCMSS Stencils, RAMC Arena Continuum
    ├── hsns/              # Hyper-Stride Native Synthesis: SIMD Vector Streamer, Hot-Patch Ring
    ├── ccns/              # Cryptographic Capability Network: CHERI Tokens, Shield & Sword
    ├── lcvs/              # State Vitrification Engine: CLWB Hardware Freeze, Instant Thaw
    ├── anss/              # Autonomic Code Generation: Live Register Reflection, Micro-JIT
    ├── rse/               # Sovereign Spacetime Container: 6-Sector Plate, UPBP Envelope
    ├── tspa/              # NVRAM Storage Subsystem: 4-Tier Stratigraphy, Persistent NVBox
    ├── lnga/              # Synaptic Event Bus: Lock-Free SpikeChannel, 5 Reflex Arcs
    ├── osla/              # Omni-Scientific Living Architecture: 7 Natural Pillars
    ├── dcf/               # Distributed Causal Semilattices
    └── uses/              # Universal Semantic Substrate: ACRQ Rings, IP-HEE JIT Engine
```

---

## 1. Subsystem Responsibilities

1. **`ruxc`**: Top-level driver, CLI argument parsing, diagnostics, and pipeline orchestrator.
2. **`rux_eia`**: Binary contract verification, symbol hashing, and post-ABI interface stability.
3. **`rux_uses`**: In-process JIT execution engine ($<50\text{ ns}$) and ACRQ asynchronous ring queue.
4. **`rux_saes`**: Dual Virtual Alias Mapping (DVAM) for zero-syscall executable memory and instruction stream fencing.
5. **`rux_zwns`**: 4-cycle stencil synthesis and 174-byte freestanding ELF binary emission.
6. **`rux_hsns`**: 64-byte AVX-512 / AVX2 vector streaming for parallel token scanning.
7. **`rux_ccns`**: 128-bit CHERI hardware capability tokens and spatial bounds safety.
8. **`rux_lcvs`**: Sub-5ns cacheline vitrification (`CLWB`) and zero-overhead memory thawing.
9. **`rux_anss`**: Micro-JIT stencil compilation, constant folding, and register reflection.
10. **`rux_rse`**: 6-sector spacetime plate memory container and UPBP envelopes.
11. **`rux_tspa`**: NVRAM persistent memory storage and zero-WAL crash recovery.
12. **`rux_lnga`**: Lock-free SPSC circular ring channels ($<1.8\text{ ns}$) delivering compiler event spikes.
13. **`rux_osla`**: 7-pillar natural scientific numerical engine and codon stream proofreading.
