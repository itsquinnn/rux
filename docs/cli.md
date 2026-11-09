# CLI Reference

## `rux` — Rux Compiler Driver

```
Usage: rux <file.rx> [-o <out>]    Compile to standalone native binary
       rux run <file.rx>           Compile and execute immediately
       rux test                    Run unified test suite
       rux verify                  Run 3-pass bootstrap verification
       rux version                 Display version
       rux eia / uses / dcf        Run subsystem verification
       rux hsns / tspa / saes      Run subsystem verification
       rux rse / osla / ccns       Run subsystem verification
       rux lcvs / anss / zwns      Run subsystem verification
       rux lnga / rxd-test         Run subsystem verification
       rux eia-run <binary>        Execute binary via IP-HEE loader
```

### Global Flags

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |
| `-o <path>` | Output path |
| `--target=<t>` | Target architecture (see [Targets](./targets.md)) |
| `--freestanding` | Emit ~174-byte direct-syscall ELF |
| `--upbp` | Emit Universal Polyglot Binary |
| `--elf` | Emit ELF64 |
| `--pe` | Emit PE32+ |
| `--macho` | Emit Mach-O 64 |
| `--uefi` | Emit UEFI PE32+ |
| `--wasm` | Emit WebAssembly |
| `--safe` | Strict safety checking |
| `--arll-force-bridge` | Force calling convention bridge |

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
  --freestanding  Emit 174-byte direct-syscall Linux binary
  --arch <arch>   Target: x86_64, aarch64, riscv64
  -v, --verbose   Enable telemetry
  --help          Show help
```

## Package Manager (`rux pm`)

The package manager uses SemVer, lockfiles, and a registry. See `tools/pm/`.
