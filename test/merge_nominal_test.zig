const std = @import("std");
const zigma = @import("zigma");

const Int = struct {
    addInt: fn (a: u32, b: u32) u32,
};

const Float = struct {
    addFloat: fn (a: f64, b: f64) f64,
};

const Impl = struct {
    pub fn addInt(a: u32, b: u32) u32 {
        return a + b;
    }
    pub fn addFloat(a: f64, b: f64) f64 {
        return a + b;
    }
};

test "should Merge Int and Float" {
    // Given
    const IntFloat = zigma.implement(zigma.merge(Int).with(Float),).with(Impl);

    // When
    const value = IntFloat.addFloat(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}
