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

## See Also

- [Getting Started](./getting-started.md)
- [Standard Library](./stdlib.md)
- [CLI Reference](./cli.md)
