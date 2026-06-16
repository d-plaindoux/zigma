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

const Float = struct {
    pub inline fn add(a: f64, b: f64) f64 {
        return a + b;
    }
};

test "should Modularize Int and call add" {
    // Given
    const IntNumber = zigma.core.implement(Number(u32)).with(Int);

    // When
    const value = IntNumber.add(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}

test "should Modularize Float and call add" {
    // Given
    const IntNumber = zigma.core.implement(Number(f64)).with(Float);

    // When
    const value = IntNumber.add(1.5, 2.5);

    // Then
    try std.testing.expectEqual(4.0, value);
}
