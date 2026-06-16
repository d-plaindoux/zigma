const std = @import("std");
const zigma = @import("zigma");

fn Number(A: type) type {
    return struct { add: fn (a: A, b: A) callconv(.@"inline") A };
}

test "Type not a struct" {
    // Given
    _ = zigma.core.implement(Number(u32)).with(u32);
}
