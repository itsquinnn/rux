# Rux Sovereign Compiler Architecture

This document defines the structural layout and engineering principles of the Rux compiler ([`rux/compiler/`](file:///home/bishwaxyz/main/rux/compiler/)).

The compiler is organized into the **13 Sovereign Subsystems**:

```text
compiler/
├── rux.rx                 # Unified self-hosting compiler entrypoint
├── verify_5gate.rx        # EIA 5-Gate hardware verification runner
├── verify_5gate_ring.rx   # Shared EIA 5-Gate proof routines (ring + EIA subsystem suite)
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
2. **`rux_eia`**: Eternal Interface Architecture ([`compiler/subsystems/eia/`](file:///home/bishwaxyz/main/rux/compiler/subsystems/eia/), see [`docs/eia-spec.md`](file:///home/bishwaxyz/main/rux/docs/eia-spec.md)). Embeds and verifies 96-byte `UniversalHologramHeader` containers (`abi_epoch = (major << 16) | minor`) carrying unkeyed 64-bit BLAKE3-sealed (`"EIAMV2\0\0"`/`"EIAROOT1"`, `EIA_FLAG_HAS_CODE_HASH`) `SymbolContract[]` (domain-separated `"EIA_SIG2"` `type_sig_hash` with dedicated `ret_is_ptr` slot + fallback `sys_exit`/`eval` contract registration), `EiaRelocHole[]`, and `EiaTypeGraphEntry[]` tables across ELF64/freestanding/`-c`/`-shared`/UPBP, static `.a` archives (GNU `/0` `/16` longnames, ELF & Mach-O object members), PE32+/UEFI (`.eia` section), Mach-O (`__EIA` segment), and Wasm (`"eia"` custom section + WASI `fd_write`/`_start`). Enforces integrity, contract, and major `abi_epoch` (`-9`) checks across `eia-check`, `eia-link-check`, `eia-relink`, `iphee_exec_binary` (`eia-run`), and `continuum` host execution; emits and resolves `DISP32`, `CALL32`, `LEA32`, and x86_64 `WIDEN_STENCIL` (`>= 128`-byte field offsets) with branch-range/bounds validation across `x86_64`, `ARM64`, and `RISC-V`; and performs offline multi-image provider splicing across ELF64 `.text` (and transitive `.a` members), PE32+ `.pcode`, and Mach-O `__PCODE` (`vmaddr >= 0x100000000`). `verify_5gate` exercises the 5-Gate ring (1: Syscall Bridge, 2: Arena/Cacheline, 3: Hologram/Contracts/Relocs/BLAKE3, 4: RXD Vitrification, 5: Self-Hosting Binary & Embedded Hologram). `blake3_root` is an unkeyed integrity digest (not a cryptographic signature), `eia-relink` is offline (not a runtime `ld.so`), and mandatory container formats (`ELF64`/`PE32+`/`Mach-O`/`Wasm`/`ar`), CPU calling conventions, OS syscalls, and C FFI ABIs remain preserved platform boundaries.
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
