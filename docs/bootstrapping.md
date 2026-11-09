# Bootstrapping

Rux is self-hosting: the compiler is written in Rux and compiles itself through a
3-pass Ken Thompson fixpoint verification.

## The 3-Pass Process

```
Pass 1: Stage-0 (Seed)      compiles compiler.rx  →  Stage-1 Binary
Pass 2: Stage-1 Binary      compiles compiler.rx  →  Stage-2 Binary
Pass 3: Stage-2 Binary      compiles compiler.rx  →  Stage-3 Binary
Gate:   ASSERT: hash(Stage-2) == hash(Stage-3)  [bitwise identical]
```

When Stage-2 and Stage-3 are bitwise identical, the compiler has converged to a
fixed point — mathematically guaranteeing zero compiler mutation and absolute
reproducibility.

## Bootstrap Files

| File | Description |
|------|-------------|
| `bootstrap/stage0/stage0_seed.rx` | Stage-0 seed compiler driver |
| `bootstrap/stage0/bootstrap_host.rx` | Zero-dependency Python host builder |
| `bootstrap/stage1/stage1_entry.rx` | Stage-1 self-hosting compiler entry |
| `bootstrap/driver/bootstrap.rx` | 3-pass bootstrap runner |
| `bootstrap/driver/compiler.rx` | Bootstrap compiler driver |

## Running Bootstrap

```bash
# Stage-0: build stage0_bin from seed
python3 bootstrap/stage0/bootstrap_host.rx bootstrap/stage0/stage0_seed.rx build_stages/stage0_bin

# Stage-1: build stage1_bin using stage0_bin
./build_stages/stage0_bin

# Verify fixpoint
./bin/rux verify
```

## See Also

- `bootstrap/README.md` — Human architecture guide
- `bootstrap/stage0/README.md` — Stage-0 execution guide
- `bootstrap/stage1/README.md` — Fixpoint convergence gate
