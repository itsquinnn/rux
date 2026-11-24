# Rux Language Specification

Rux is a statically typed, compiled systems programming language with syntax inspired by
modern systems languages and semantics designed for bare-metal and hosted execution.

## Lexical Structure

- Comments: not used in source files (zero-comment convention)
- Identifiers: start with a letter or underscore, followed by alphanumeric characters
- Keywords: `fn`, `let`, `mut`, `return`, `if`, `else`, `while`, `for`, `break`, `continue`,
  `struct`, `enum`, `trait`, `impl`, `unsafe`, `include`, `as`, `true`, `false`, `null`, `nil`
- Literals: integers (`42`, `0xFF`, `0b1010`), floats (`3.14`), strings (`"hello"`), chars (`'a'`)

## Types

### Primitive Types
- `int`, `uint` — native word-sized integers
- `u8`, `u16`, `u32`, `u64` — unsigned fixed-width
- `i8`, `i16`, `i32`, `i64` — signed fixed-width
- `f32`, `f64` — floating point
- `bool` — boolean
- `byte` — alias for `u8`
- `any` — dynamically tagged value
- `unknown` — gradually typed value

### Composite Types
- Arrays: `[T; N]`
- Slices: `[]T`
- Structs: `struct Name { field: T, ... }`
- Enums: `enum Name { A, B(T) }`
- Tuples: `(T1, T2, ...)`
- Pointers: `*const T`, `*mut T`
- Functions: `fn(Args) -> Ret`

## Declarations

```rx
// Constants
const MAX: uint = 100;

// Type aliases
type Result<T> = ...;

// Structs
struct Point {
    x: f64,
    y: f64,
}

// Enums
enum Option<T> {
    Some(T),
    None,
}

// Traits
trait Drawable {
    fn draw(&self);
}

// Implementations
impl Drawable for Point {
    fn draw(&self) {
        println("draw point");
    }
}

// Functions
fn add(a: int, b: int) -> int {
    return a + b;
}

// Extern functions
extern fn printf(fmt: *const byte, ...) -> int;
```

## Statements and Expressions

- Variable binding: `let x = 42;` (immutable by default)
- Mutable binding: `let mut x = 42;`
- Conditional: `if cond { ... } else { ... }`
- Loops: `while cond { ... }`, `for ... { ... }`
- Control flow: `break`, `continue`, `return expr`
- Match: `match expr { pattern => expr, _ => expr }`
- Unsafe blocks: `unsafe { ... }`
- Defer: `defer expr;` (runs on scope exit)
- Ternary: `cond ? a : b`
- Optional chaining: `expr?`

## Memory Model

Rux uses affine lexical ownership (ALOR):
- Values have a single owner
- Ownership transfers on assignment
- Borrowing via references (`&T`, `&mut T`)
- No garbage collector; deterministic cleanup via `defer` and RAII
- Manual memory management available in `unsafe` blocks

## Build Configuration (`.rxd`)

```rxd
package {
    name: "my-app"
    version: "1.0.0"
    edition: "2026"
}

build {
    opt_level: 3
    freestanding: false
    target_arch: "x86_64"
    features: ["avx512"]
}
```

## Ergonomic & Pythonic Syntax Forms

In addition to systems syntax (`fn`, `println`, `&&`, `!`, `Vec`, `HashMap`), `compiler/rsc` supports ergonomic forms including `def`, `say`, `elif`, `and`, `not`, `ensure`, collection literals (`vec[...]`, `set{...}`, `map{...}`), string operations (`.to_str()`, `.len()`, `.is_empty()`, `+` concatenation across AOT, interpreter, bytecode VM, JIT, and ISO C99 transpilation), contextual `gen` (generator modifier before `fn`/`pub`/`async`/`unsafe`/`const`, usable as an identifier elsewhere), `for item in vec` iteration, and `mod`/`use` module imports.

## Eternal Interface Architecture (EIA)

Compiled artifacts carry a 96-byte `UniversalHologramHeader` (`magic = 0x4849457F`, versioned by `abi_epoch = (major << 16) | minor`) indexing three tables sealed by an **unkeyed 64-bit BLAKE3 integrity digest** (`blake3_root`, combining EIA metadata tables and executable code sections via `EIA_FLAG_HAS_CODE_HASH`):

1. **`SymbolContract[]`**: Per-symbol `symbol_hash`, `type_sig_hash`, `vaddr`, `code_size`, `flags` (including `EIA_SYM_IMPORT = 2` for `extern` declarations), `param_conv`, and `contract_digest`.
2. **`EiaTypeGraphEntry[]`**: Canonical type and field offsets used by `eia_patch_binary_relocs_span` / `eia_relink_binary_bytes_ex` for post-ABI layout resolution and binary relinking.
3. **`EiaRelocHole[]`**: Relocation records (`DISP32`, `CALL32`, `LEA32`, and `WIDEN_STENCIL` for `>= 128`-byte field offsets) across ELF64/freestanding/UPBP/static `.a` archives, PE32+/UEFI (`.eia` section), Mach-O (`__EIA` segment), and Wasm (`"eia"` custom section, alongside WASI `fd_write` + `_start`).

**Scope & Platform Boundaries**: EIA verifies metadata + multi-section executable code integrity across binaries and `!<arch>\n` `.a` archives (`eia-check`), cross-unit symbol/type contracts plus major/minor `abi_epoch` compatibility (`-9` rejection across incompatible major epochs in `eia-link-check`), **offline** post-ABI layout relinking and provider splicing (`eia-relink`: ELF64/UPBP `.text`, PE32+ `.pcode`, Mach-O `__PCODE` across `x86_64`, `ARM64`, and `RISC-V`), and hologram-validated execution (`eia-run` / `iphee_exec_binary`). `blake3_root` is an unkeyed 64-bit integrity digest (not an asymmetric cryptographic signature or MAC), `eia-relink` is offline rather than a runtime `ld.so` dynamic loader, and mandatory container formats (`ELF64`/`PE32+`/`Mach-O`/`Wasm`/`ar`), CPU calling conventions, OS syscalls, and foreign C FFI ABIs remain intentionally preserved beneath EIA.

## See Also

- [EIA Specification](./eia-spec.md)
- [Getting Started](./getting-started.md)
- [Standard Library](./stdlib.md)
- [CLI Reference](./cli.md)
