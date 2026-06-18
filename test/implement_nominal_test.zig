const std = @import("std");
const zigma = @import("zigma").module;

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

test "should modularize Int Number and call add" {
    // Given
    const IntNumber = zigma.implement(Number(u32)).using(Int);

    // When
    const value = IntNumber.add(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}

test "should modularize Float Number and call add" {
    // Given
    const IntNumber = zigma.implement(Number(f64)).using(Float);

    // When
    const value = IntNumber.add(1.5, 2.5);

    // Then
    try std.testing.expectEqual(4.0, value);
}
