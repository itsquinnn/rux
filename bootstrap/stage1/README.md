# Stage-1 Self-Hosting Compiler (`rux/src/bootstrap/stage1/`)

## 1. Purpose & Verification Gate

Stage-1 is the first generation of the compiler built by Stage-0. Its primary mission is to:
1. Compile the full compiler source code to produce **Stage-2 Binary**.
2. Run Stage-2 to compile the same source code to produce **Stage-3 Binary**.
3. Pass through the **Ken Thompson Fixpoint Gate**:
   $$\text{hash}(\text{Stage-2}) \equiv \text{hash}(\text{Stage-3})$$

## 2. Invariant Guarantee

Once Stage-2 and Stage-3 are bitwise identical:
- The compiler is mathematically proven to be self-hosting.
- No host environmental artifacts or nondeterminism remain in the output binary.
- All subsequent production releases of `rux` inherit this exact fixpoint seal.
