const std = @import("std");
const zigma = @import("zigma");

fn Number(A: type) type {
    return struct {
        add: fn (a: A, b: A) callconv(.@"inline") A,
    };
}

const Int = struct {
    pub inline fn add(a: u32, b: u32) u32 {
        return a + b;
    }
};

test "should Modularize IntAdd and call add" {
    // Given
    const IntNumber = zigma.implement(Number(u32)).with(Int);

    // When
    const value = IntNumber.add(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}
