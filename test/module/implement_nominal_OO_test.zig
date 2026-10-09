const std = @import("std");

const zigma = @import("zigma").module;

fn Figure(comptime Self: type) type {
    return struct {
        surface: fn (self: Self) callconv(.@"inline") f64,
    };
}

const Circle = struct {
    radius: u32,

    pub inline fn surface(self: @This()) f64 {
        return std.math.pi * std.math.pow(f64, @as(f64, self.radius), 2);
    }

    pub fn init(radius: u32) @This() {
        return .{ .radius = radius };
    }
};

test "should compute circle surface" {
    // Given
    const data = Circle.init(10);
    const circleFigure = zigma.implement(Figure(Circle)).using(Circle);

    // When
    const surface = circleFigure.surface(data);

    // Then
    try std.testing.expectEqual(std.math.pi * 100.0, surface);
}
