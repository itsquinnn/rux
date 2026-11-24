# Eternal Interface Architecture (EIA) Specification

> Authoritative binary layout, integrity model, contract verification, offline relinking, and platform boundaries for EIA v1 (`compiler/subsystems/eia/*`).

---

## 1. Overview & Explicit Platform Boundaries

The **Eternal Interface Architecture (EIA)** embeds structured interface contracts, canonical struct-field layout graphs, and relocation metadata directly inside compiled artifacts, sealed by an unkeyed 64-bit BLAKE3 integrity digest (`blake3_root`).

**Platform boundaries (preserved intentionally):**
- Mandatory platform/OS container formats (`ELF64`, `PE32+`, `Mach-O 64`, `WebAssembly`, UNIX `ar`), CPU calling conventions, OS/UEFI syscalls, and foreign C/FFI ABIs remain required; EIA operates **on top of** them.
- `blake3_root` is an **unkeyed 64-bit BLAKE3 integrity digest** detecting corruption and un-re-sealed modification; it is **not** a keyed MAC or asymmetric signature defending against an adversary who re-computes and re-seals the header.
- `eia-relink` is an **offline** post-ABI relinker and multi-image provider splicer (`rux eia-relink`), not a runtime dynamic loader (`ld.so`).

---

## 2. Binary Record Layouts (Little-Endian)

### 2.1 `UniversalHologramHeader` — 96 bytes

| Offset | Size | Type | Field | Description |
|---|---|---|---|---|
| `0x00` | 4 | `u32` | `magic` | `EIA_MAGIC = 0x4849457F` (`\x7FEIH`) |
| `0x04` | 4 | `u32` | `version` | `EIA_VERSION = 0x00010001` |
| `0x08` | 8 | `uint` | `abi_epoch` | `(major << 16) \| minor` (`EIA_EPOCH_MAJOR_SHIFT = 16`) |
| `0x10` | 8 | `uint` | `contracts_offset` | File offset of `SymbolContract[]` |
| `0x18` | 8 | `uint` | `contracts_count` | Number of 48-byte `SymbolContract` entries |
| `0x20` | 8 | `uint` | `relocs_offset` | File offset of `EiaRelocHole[]` |
| `0x28` | 8 | `uint` | `relocs_count` | Number of 24-byte `EiaRelocHole` entries |
| `0x30` | 8 | `uint` | `type_graph_offset` | File offset of `EiaTypeGraphEntry[]` |
| `0x38` | 8 | `uint` | `type_graph_size` | Byte length of `EiaTypeGraphEntry[]` (`count * 24`) |
| `0x40` | 8 | `uint` | `blake3_root` | Sealed unkeyed 64-bit BLAKE3 integrity root |
| `0x48` | 8 | `uint` | `flags` | Bitmask of `EIA_FLAG_*` |
| `0x50` | 8 | `uint` | `reserved0` | Code/text section base anchor (`text_vaddr` or file offset) |
| `0x58` | 8 | `uint` | `reserved1` | Immutable rodata section anchor (`rodata_vaddr` or offset) |

**Header `flags` (`EIA_FLAG_*`):**
- `EIA_FLAG_SEALED = 1` — `blake3_root` has been populated over the metadata tables (cleared before hashing table metadata).
- `EIA_FLAG_HAS_CODE_HASH = 2` — `blake3_root` folds the artifact digest (`eia_compute_artifact_sealed_digest`) with the table digest (`eia_header_combine_digests`).
- `EIA_FLAG_FREESTANDING = 4` — Artifact is a freestanding ELF vessel without section headers (`SHT`).
- `EIA_FLAG_BRIDGE = 8` — Artifact carries or requests cross-ABI calling-convention bridge handling (`--arll-force-bridge`).

Bounds validation (`eia_header_tables_in_bounds`) enforces overflow-safe arithmetic (`contracts_count * 48`, `relocs_count * 24`, wrap-free `offset + size <= file_len`) and pairwise non-overlap across the header (`[holo_off .. holo_off + 96)`) and all three tables.

**Domain-separated BLAKE3 header & root tags (`header.rx`):**
- Table/header accumulator (`eia_mix_labeled_u64`) prefixes every 40-byte mix block with `"EIAMV2\0\0"`, hashing header fields (`0x48445231`..`0x48445234`) and each non-empty table (`0x54424C43` contracts, `0x54424C52` relocs, `0x54424C54` type graph).
- Root combination (`eia_header_combine_digests`) hashes a 24-byte `"EIAROOT1"` + `tables_b3` + `code_b3` record when `EIA_FLAG_HAS_CODE_HASH` is set.

---

### 2.2 `SymbolContract` — 48 bytes

| Offset | Size | Type | Field | Description |
|---|---|---|---|---|
| `0x00` | 8 | `uint` | `symbol_hash` | 64-bit BLAKE3 hash of symbol name |
| `0x08` | 8 | `uint` | `type_sig_hash` | 64-bit BLAKE3 hash of canonical signature |
| `0x10` | 8 | `uint` | `vaddr` | Symbol virtual address (`0` when `EIA_SYM_IMPORT`) |
| `0x18` | 8 | `uint` | `code_size` | Emitted code size in bytes (`0` when `EIA_SYM_IMPORT`) |
| `0x20` | 4 | `u32` | `flags` | `EIA_SYM_DEFINED = 1`, `EIA_SYM_IMPORT = 2`, `EIA_SYM_PUBLIC = 8` |
| `0x24` | 4 | `u32` | `param_conv` | Calling-convention identifier |
| `0x28` | 8 | `uint` | `contract_digest` | 64-bit BLAKE3 digest of bytes `[0x00 .. 0x28)` |

`eia_verify_contracts_table` rejects null pointers with non-zero counts, zero `symbol_hash` or `type_sig_hash`, contradictory `EIA_SYM_DEFINED | EIA_SYM_IMPORT` flags, and invalid `contract_digest` values with `-4`.

Contract emission notes:
- In `compiler/rsc`, symbol/type name hashes use 64-bit FNV-1a (`hash_identifier`), while `codegen_x86_stmt.rx` emits `register_fn_contract_ex` and `runtime_guard.rx` emits/promotes fallback runtime contracts (`sys_exit`, `eval`) as `EIA_SYM_DEFINED`.
- In `compiler/pipeline/pipeline.rx`, non-import `NODE_FN` nodes require exact span metadata (`(is_mut & 4) != 0`), failing compilation with `EMISSION_FAILED` if missing rather than fabricating sizes.

---

### 2.3 `EiaTypeGraphEntry` — 24 bytes

| Offset | Size | Type | Field | Description |
|---|---|---|---|---|
| `0x00` | 8 | `uint` | `type_sig_hash` | 64-bit BLAKE3 hash of canonical struct/type name |
| `0x08` | 8 | `uint` | `field_hash` | 64-bit BLAKE3 hash of field name |
| `0x10` | 4 | `u32` | `byte_offset` | Byte offset of field within struct |
| `0x14` | 4 | `u32` | `field_size` | Size of field in bytes |

---

### 2.4 `EiaRelocHole` — 24 bytes

| Offset | Size | Type | Field | Description |
|---|---|---|---|---|
| `0x00` | 4 | `u32` | `insn_offset` | Byte offset relative to code section base |
| `0x04` | 4 | `u32` | `patch_kind` | `1 = DISP32`, `2 = CALL32`, `3 = LEA32`, `4 = WIDEN_STENCIL` |
| `0x08` | 8 | `uint` | `type_sig_hash` | Struct type hash (`DISP32`/`LEA32`/`WIDEN_STENCIL`) or symbol hash (`CALL32`) |
| `0x10` | 8 | `uint` | `field_or_sym_hash` | Field hash (`DISP32`/`LEA32`/`WIDEN_STENCIL`) or target symbol hash (`CALL32`) |

---

## 3. Canonical Signature Hash Format (`"EIA_SIG2"`)

Both `compiler/rsc/crypto/crypto.rx` (`compute_canonical_sig_hash_ex`) and `compiler/pipeline/pipeline.rx` (`pipeline_compute_sig_hash`) compute `SymbolContract.type_sig_hash` from a domain-separated little-endian buffer of length `32 + param_cnt * 16` (1056-byte stack fast-path up to 64 params, with dynamic `uses_alloc`/`mmap` fallback above 64):

1. `[0x00..0x08)`: ASCII `"EIA_SIG2"` (8-byte domain separator)
2. `[0x08..0x0C)` (`u32`): `param_cnt`
3. `[0x0C..0x10)` (`u32`): `calling_conv`
4. `[0x10..0x18)` (`u64`): `ret_type_hash`
5. `[0x18..0x20)` (`u64`): `ret_is_ptr` (dedicated pointer-return discriminator slot; `compute_canonical_sig_hash` passes `0`)
6. Repeated `param_cnt` times (`16` bytes each starting at `0x20`):
   - `+0` (`u64`): `param_type_hash`
   - `+8` (`u64`): `param_ptr_kind`
7. Digest = `blake3_hash64(buf, 32 + param_cnt * 16)`.

---

## 4. Container Placement

`eia_locate_hologram_offset` discovers holograms across supported containers:
- **Raw / Blob**: `UniversalHologramHeader` at offset `0`.
- **ELF64 / Freestanding ELF / `-c` `.o` / `-shared` `.so`**: embedded at offset `128` (`0x80`) or in the `.eia` section header (`SHT`).
- **UPBP Polyglot**: 1024-byte `MZ`+PE prefix before ELF64, placing the hologram at `1152` (`1024 + 128`).
- **Static Archive (`.a`)**: UNIX `!<arch>\n` (`eia_is_ar_archive`), skipping GNU `"/"`, GNU `"//"` string table, `"/SYM64/"`, and BSD `"__.SYMDEF"` special members while supporting GNU longnames (`/0`, `/16`, ...). **All** ELF64 (`mk == 1`) and Mach-O 64 (`mk == 3`) object members are verified (`eia_verify_artifact_bytes`, `-1` if zero verifiable members), and `driver_load_and_verify_eia` checks major `abi_epoch` (`-9`) on every member.
- **PE32+ / UEFI**: `.eia` COFF section; offline spliced code resides in `.pcode` with RVAs mapped via section headers (`eia_pe_file_off_to_rva`).
- **Mach-O 64**: `__EIA` segment; offline spliced code resides in `__PCODE` mapped at `vmaddr >= 0x100000000` (and immutable data in `[reserved1 .. holo_off)`).
- **WebAssembly**: custom section `"eia"` (`sec_id = 0`, LEB128 length, name `\x03eia`) placed after Code (`sec_id = 10`) / Data (`sec_id = 11`).

---

## 5. Sealed Integrity Digest Scope

When `EIA_FLAG_HAS_CODE_HASH` is set, `eia_compute_artifact_sealed_digest` deterministically folds executable code (`eia_locate_code_span`), container metadata, and immutable/data sections via `eia_acc_digest` (and `eia_span_overlaps_holo` to exclude the `.eia`/`__EIA` hologram bytes themselves):
- **ELF64 (with `SHT`)**: header metadata (`e_type`, `e_machine`, `e_version`, `e_entry`, `e_phoff`, `e_shoff`, `e_phentsize..e_shstrndx`), full Program Header Table (`e_phoff`), executable code span, and every `SHF_ALLOC` non-`NOBITS` non-exec-`PROGBITS` section (`.rodata`, `.data`, etc.) with `(sh_type, sh_flags, sh_addr, sh_size)` metadata. UPBP artifacts also hash the 128-byte PE/polyglot stub (`buf[0..128)`).
- **Freestanding ELF (no `SHT`, `EIA_FLAG_FREESTANDING`)**: header & PHT metadata, executable code span, and trailing immutable data `[code_off + code_len .. file_len)`.
- **PE32+**: PE metadata (`Machine`, `NumberOfSections`, `Magic`, `NumberOfRvaAndSizes`, `AddressOfEntryPoint`, `SizeOfImage`, `ImageBase`), executable span (`.text` and offline `.pcode`), and every non-`.eia` non-`IMAGE_SCN_MEM_EXECUTE` section (e.g. `.rdata`, `.rodata`, `.data`, `.idata`) with `(VirtualAddress, VirtualSize, span_len, Characteristics)` metadata.
- **Mach-O 64**: `mach_header_64` fields, `LC_MAIN` (`0x80000028`) payload (`entryoff`, `stacksize`), executable span (`__text`, `__PCODE`), non-special `LC_SEGMENT_64` segments (`!__TEXT && !__PCODE && !__EIA && !__PAGEZERO`, e.g. `__DATA`), and immutable `__rodata` range `[reserved1 .. holo_off)`.
- **WebAssembly**: 8-byte Wasm header, Code section (`sec_id == 10`), and every standard section (`sec_id` in `1..12`, `!= 10`, e.g. Type `1`, Import `2`, Export `7`, Data `11`) with `(sec_id, slen)` framing; Wasm binaries carrying non-zero `relocs_count` are rejected with `-3`.

This artifact digest is combined with the tables-only `"EIAMV2\0\0"` BLAKE3 digest via `"EIAROOT1"` in `eia_header_combine_digests`. Any un-re-sealed modification to covered headers, metadata tables, executable instructions, or data/rodata/import/export sections fails `eia-check` / `eia_verify_artifact_bytes` with `-3`.

---

## 6. Relocations & Offline Relinking (`eia-relink`)

- **Type-graph field patching**: `DISP32` (`1`), `LEA32` (`3`), and `WIDEN_STENCIL` (`4`, for `>= 128`-byte x86_64 displacements) resolve `EiaTypeGraphEntry.byte_offset` across `x86_64`, `ARM64`, and `RISC-V` encodings in `eia_patch_single_hole`; `eia_verify_relocs_in_span` enforces `req_sz = 8` for ARM64/RISC-V data relocs and `WIDEN_STENCIL`.
- **Call resolution & branch range bounds**: `CALL32` (`2`) resolves cross-unit call targets across `x86_64` relative `E8`, `ARM64` `BL`, and `RISC-V` `JAL` encodings (`eia_patch_call_hole_span` / `eia_patch_call_hole_pe`). `eia_patch_branch_at_offset` returns `false` (`-7`) on unaligned or out-of-range branches (`x86_64` signed 32-bit, `ARM64` 4-byte aligned `[-33554432, 33554431]` word offset, `RISC-V` 2-byte aligned `[-1048576, 1048574]` byte offset); partial reloc counts fail with `-7`.
- **Chained & `.a` multi-member relinking**: `rux eia-relink <client> <p1> [p2 ...] -o <out>` rejects `.a` archives as clients, grows buffers dynamically (`driver_ensure_buf_cap`), resolves multi-member `.a` archives via iterative transitive member passes (`eia_relink_binary_bytes_step`), invokes partial mode (`require_all_resolved = false`) for intermediate providers and strict mode (`require_all_resolved = true`) on the final provider, splices `.text`/`.rodata` (ELF64), `.pcode` (PE32+), or `__PCODE` (Mach-O), verifies exact complete file writes (`wr == c_len`), and re-seals `blake3_root`.

---

## 7. Consume-Path Enforcement (`eia-run`, `iphee_exec_binary`, `continuum`)

Before execution, `iphee_exec_binary` (`compiler/rsc/core/sys.rx`) and host execution in `continuum.rx` (`sys_verify_eia_executable_bytes`) enforce fail-closed checks:
1. Requires non-empty (`>= 64` bytes), untruncated (`nread < max_bin_size`, using dynamic `sys_read_file_alloc`) host `x86_64` ELF64 or UPBP binaries — rejects `.a` archives (`-2`), unlinked `ET_REL` objects (`-2`), and non-`x86_64` architectures (`-3`).
2. Requires a valid sealed EIA hologram (`-2` if missing/corrupt) and passes `eia_verify_artifact_bytes` (`-3` on BLAKE3 tamper).
3. Enforces `eia_epochs_compatible` with the runner (`-9` on major epoch mismatch).
4. Rejects execution if any `SymbolContract` still carries `EIA_SYM_IMPORT` without a compatible `EIA_SYM_DEFINED` entry (`-5`), if `main` lacks `type_sig_hash` (`-5`), if `main_off` lies outside `[ip_coff, ip_coff + ip_clen)` (`-2`), or if `patched != holo.relocs_count` during IP-HEE relocation patching (`-7`).

---

## 8. Canonical Error Codes

| Code | Meaning |
|---|---|
| `0` | Success (or `>= 0` resolved import count in `eia_verify_cross_unit_contracts_step`) |
| `-1` | Missing or unrecognized container / hologram / Wasm or `ar` structure |
| `-2` | Corrupt `UniversalHologramHeader`, zero digest on sealed header, table bounds overflow, or table overlap |
| `-3` | BLAKE3 integrity digest mismatch (`blake3_root`) |
| `-4` | Invalid `SymbolContract` table, null table, `DEFINED \| IMPORT` contradiction, or bad `contract_digest` |
| `-5` | Unresolved `EIA_SYM_IMPORT` symbol |
| `-6` | Contract mismatch (`type_sig_hash` / `param_conv`) or cross-arch / incompatible splice section |
| `-7` | Invalid `patch_kind` (outside `1..4`), missing `EiaTypeGraphEntry`, reloc offset out of span, out-of-range branch, or partial reloc failure |
| `-8` | Insufficient relink buffer capacity, cross-format mismatch, or splice failure |
| `-9` | Major `abi_epoch` mismatch (`client_epoch >> 16 != provider_epoch >> 16`) |
