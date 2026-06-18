# Zigma

**Algebraic Abstractions, Formal Invariants, and Zero-Cost Contracts for Zig.**

Zigma is a lightweight, zero-cost framework that brings the power of modularity—inspired by OCaml functors, and Rust traits—to systems programming in Zig. By leveraging pure `comptime` reflection, Zigma allows you to define strict **specifications** bundled with mathematical **invariants**, guaranteeing that your implementations are correct by construction with absolutely zero runtime overhead.

---

## The Problem
In systems programming, interfaces are often implicit (duck typing) or polymorphic at runtime (VTables). 
* **Implicit interfaces** lead to cryptic compiler errors deep within your generics when an implementation breaks a contract.
* **Runtime interfaces** (like `std.mem.Allocator`) introduce pointer indirections and prevent compiler optimizations.
* More importantly, traditional interfaces only check *types*, not *logic*. They cannot guarantee that your data structures respect the necessary semantic laws (invariants) during development.

## The Zigma Solution
Zigma allows you to treat algebraic specifications as first-class citizens. By combining compile-time introspection with an ergonomic, Rust-inspired DSL, Zigma:
1. **Validates Signatures:** Ensures your structures strictly adhere to the required contract before running any code.
2. **Embeds Semantic Invariants:** Bundles mathematical assertions (e.g., Stack LIFO behavior) directly within the specification.
3. **Guarantees Maximum Performance:** Uses compile-time evaluation and forced inlining to completely erase the abstraction barrier in the final machine code.

---

## Sketch

> NOTE: Work in progress for the design and the implementation

### 1. Define the Specification and Invariants
Declare your interface layout and embed its mathematical laws directly within the struct namespace. Notice we can also use of `callconv(.@"inline")` to enforce performance constraints.

```zig
const std = @import("std");
const Pair = ...;

fn Stack(comptime T: fn (type) type, comptime A: type) type {
    return struct {
        
        create: fn () callconv(.@"inline") T(A),
        push: fn (std.mem.Allocator, A, T(A)) anyerror!T(A),
        peek: fn (T(A)) ?A,
        pop: fn (std.mem.Allocator, T(A)) Pair(?A, T(A)),

        //
        // Invariants
        // 
        
        fn @"S.peek(S.create()) = null"(Impl: @This()) !void {
            const stack = Impl.create();
            try std.testing.expectEqual(null, Impl.peek(stack));
        }
        
        fn @"S.peek(S.push(a, S.create())) = a"(
            Impl: @This(),
            allocator: std.mem.Allocator,
            a: A,
        ) !void {
            const stack = try Impl.push(allocator, a, Impl.create());
            defer @TypeOf(stack).deinit(allocator, stack);

            try std.testing.expectEqual(a, Impl.peek(stack));
        }
        
        // ...
        
        pub fn checkInvariants(Impl: @This(), allocator: std.mem.Allocator, a: A) !void {
            try Impl.@"S.peek(S.create()) = null"();
            try Impl.@"S.peek(S.push(a, S.create())) = a"(allocator, a);
        }
    };
}
```

### 2. Implement a Pure Incarnation

Your implementation remains a clean, decoupled, and highly cohesive struct. It does not need to know about the specification or metadata; it just provides the functions.

```zig
fn StackList(comptime A: type) type {
    return struct {
        inline fn create() List(A) { 
            return .nil(); 
        }
        
        fn push(allocator: std.mem.Allocator, a: A, l: List(A)) anyerror!List(A) {
            return try .cons(allocator, a, l);
        }
        
        fn peek(l: List(A)) ?A { 
            // ... 
        }
        
        fn pop(allocator: std.mem.Allocator, l: List(A)) Pair(?A, List(A)) { 
            // ... 
        }
    };
}

```

### 3. Bind and Verify via the DSL

Use Zigma's `impl` DSL to safely instantiate and test your implementation against the specification.

```zig
test "should check Stack invariants for StackList incarnation" {
    const allocator = std.testing.allocator;

    // Bind the incarnation to the specification (Rust-like syntax)
    const checker = impl(Stack(List, u32)).with(StackList(u32));

    // Run the embedded algebraic tests
    try checker.checkInvariants(allocator, 42);
}

```

---

## Key Features

### Compile-Time Contract Enforcement

No more runtime crashes due to mismatched interfaces. If your implementation misses a method or alters a signature, Zigma halts the compilation immediately with clean, tailored, and descriptive error messages pointing out exactly what is wrong.

### Guaranteed Inlining (`callconv(.@"inline")`)

Unlike traditional interface patterns that rely on function pointers or VTables, Zigma allows you to enforce inlining constraints directly at the signature level. By applying `callconv(.@"inline")` to the specification's function types, the compiler **forces** the incarnation's code directly into the call site. This eliminates function call overhead entirely (no register saving, no stack manipulation) and unlocks powerful compiler optimization passes across your abstraction boundaries.

### Property-Based Design

Decouple your architecture from your validation logic. Write your invariant test suites once inside the specification struct, and automatically execute them against *any* present or future implementation of that interface.

---

## Core Architecture

Zigma operates on a highly clean 2-tier abstraction structure, all resolved during compilation:

* **The Engine (`Validator`):** Handles static introspection and structural mapping.
* **The DSL (`implement`):** Exposes an ergonomic `implement(Spec).with(Impl)` syntax.

---

## Why Use Zigma?

* **For Library Authors:** Expose bulletproof abstractions. When users implement your traits, they are instantly warned by the compiler if they break either your structural layout or your behavioral invariants.
* **For Systems Engineers:** Safely encapsulate critical, low-level components (allocators, database engines, network protocols) without sacrificing raw performance.
* **For Functional Programmers:** Bring the mathematical rigor of Algebraic Data Types and Module Functors directly into a low-level language.

## License

```
MIT License

Copyright (c) 2026 Didier Plaindoux

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```