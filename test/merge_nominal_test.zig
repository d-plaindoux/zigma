const std = @import("std");
const zigma = @import("zigma").module;

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

test "should combine; Int and Float types and call addInt" {
    // Given
    const IntFloat = zigma.implement(zigma.combine(Int).with(Float)).using(Impl);

    // When
    const value = IntFloat.addInt(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}

test "should combine Int and Float types and call addFloat" {
    // Given
    const IntFloat = zigma.implement(zigma.combine(Int).with(Float)).using(Impl);

    // When
    const value = IntFloat.addFloat(1, 2);

    // Then
    try std.testing.expectEqual(3, value);
}
