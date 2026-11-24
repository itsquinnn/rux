# CLI Reference

## `rux` — Rux Compiler Driver

```
Usage: rux <file.rx> [-o <out>]    Compile to standalone native binary
       rux run <file.rx>           Compile and execute immediately
       rux test                    Run unified test suite
       rux verify                  Run 5-Gate EIA verification ring (syscalls, cacheline, hologram/BLAKE3, RXD, self-hosting fixpoint)
       rux version                 Display version
       rux eia / uses / dcf        Run subsystem verification
       rux hsns / tspa / saes      Run subsystem verification
       rux rse / osla / ccns       Run subsystem verification
       rux lcvs / anss / zwns      Run subsystem verification
       rux lnga / rxd-test         Run subsystem verification
       rux eia-check <bin|lib.a>   Validate EIA hologram, unkeyed 64-bit BLAKE3 digest (including ELF & Mach-O `.a` members) & major `abi_epoch`
       rux eia-link-check <c> <p1> [p2 ...] Verify cross-unit SymbolContract compatibility, transitive imports & major `abi_epoch` (`-9`) across binaries or `.a` providers
       rux eia-relink <c> <p1> [p2 ...] -o o Offline post-ABI relink & chained multi-image splice (ELF64 `.text`/`.a` providers, PE32+ `.pcode`, Mach-O `__PCODE`)
       rux eia-run <binary>        Execute EIA-sealed host `x86_64` ELF64/UPBP binary via IP-HEE loader (fail-closed on `.a`/`ET_REL`/non-host arch)
```

### Global Flags

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |
| `-o <path>` | Output path (defaults to `main.o` with `-c`, `libmain.so` with `-shared`, `a.out` otherwise) |
| `-c` | Emit relocatable `ET_REL` ELF object (`.o`) with EIA hologram |
| `-shared` | Emit shared `ET_DYN` ELF object (`.so`) with EIA hologram |
| `-target <t>`, `--target=<t>` | Target architecture (`linux`, `x86_64-linux`, `arm64`, `arm64-baremetal`, `riscv64`, `win64`, `macos`, `macos-arm64`, `uefi`, `baremetal`, `opensbi`, `wasm`, etc.; see [Targets](./targets.md)) |
| `--format=<fmt>` | Output container override (`elf`, `upbp`, `pe`, `coff`, `macho`, `uefi`, `wasm`) |
| `--mode=<m>` | Execution mode (`auto`, `aot`, `jit`, `interp`, `vm`, `repl`, `transpile-c`, `c`, `freestanding`) |
| `--freestanding` | Emit freestanding ELF64 with sealed EIA hologram |
| `--upbp` | Emit Universal Polyglot Binary |
| `--elf` | Emit ELF64 |
| `--pe` | Emit PE32+ |
| `--macho` | Emit Mach-O 64 |
| `--uefi` | Emit UEFI PE32+ |
| `--wasm` | Emit WebAssembly |
| `--safe`, `--strict-safety` | Strict safety checking |
| `--shadow=<mode>` | Shadow diagnostics mode (`off`, `warn`, `deny`) |
| `--trace-mode` | Enable execution trace mode |
| `--arll-force-bridge` | Force calling convention bridge (`EIA_FLAG_BRIDGE`) |
| `--eia-permute-seed=<hex>` | Set layout permutation seed for EIA validation |

### Examples

```bash
rux build app.rx -o app
rux run app.rx
rux build app.rx --target=win64 -o app.exe
rux build app.rx --target=ios -o app
rux build app.rx --target=android -o app
rux build app.rx --target=wasm -o app.wasm
rux build app.rx --target=uefi -o app.efi
rux build app.rx --target=baremetal --freestanding -o kernel.bin
rux build app.rx --upbp -o app
rux test
rux verify
rux eia
rux eia-check ./app
rux eia-link-check ./client ./provider
rux eia-relink ./client ./provider -o ./relinked
rux eia-run ./app
```

## `ruxc` — Rux Compiler Pipeline

```
Usage: ruxc [command] <file.rx | file.rxd> [options]

Commands:
  build <file>    Compile source file to native binary
  run   <file>    Compile and execute in-process
  test  <file>    Run unit tests embedded in source
  verify <file>   Perform 3-pass bootstrap verification

Options:
  -o <path>       Output artifact path
  --freestanding  Emit freestanding ELF64 with sealed EIA hologram
  --arch <arch>   Target: x86_64, aarch64, riscv64
  -v, --verbose   Enable telemetry
  --help          Show help
```

## Package Manager (`rux pm`)

The package manager uses SemVer, lockfiles, and a registry. See `tools/pm/`.
