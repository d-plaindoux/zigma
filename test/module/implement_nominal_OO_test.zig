const std = @import("std");

const zigma = @import("zigma");

// Interface definition
fn Area(comptime Self: type) type {
    return struct {
        surface: fn (Self) callconv(.@"inline") f64,
    };
}

fn Adder(comptime Self: type) type {
    return struct {
        add: fn (Self, Self) callconv(.@"inline") Self,
    };
}

fn Figure(comptime Self: type) type {
    return zigma.module.combine(Area(Self), Adder(Self));
}

// Implementation denotation
fn ImplOf(comptime T: fn (type) type) fn (type) type {
    return struct {
        fn run(comptime Self: type) type {
            return struct {
                self: Self,
                impl: T(Self),
            };
        }
    }.run;
}

fn impl(comptime T: fn (type) type) type {
    return struct {
        fn using(comptime Impl: type) type {
            const implementation: T(Impl) = zigma.module.implement(T(Impl)).using(Impl);
            return struct {
                fn init(v: Impl) type {
                    return zigma.abstraction.Exists(ImplOf(T)).pack(
                        Impl,
                        .{
                            .self = v,
                            .impl = implementation,
                        },
                    );
                }
            };
        }
    };
}

// Defines candidates

const Rect = struct {
    w: f64,
    h: f64,
    pub inline fn surface(self: @This()) f64 {
        return self.w * self.h;
    }
    pub inline fn add(self: @This(), other: @This()) @This() {
        return .{ .w = self.w + other.w, .h = self.h + other.h };
    }
};

const Circle = struct {
    r: f64,
    pub inline fn surface(self: @This()) f64 {
        return std.math.pi * self.r * self.r;
    }
    pub inline fn add(self: @This(), other: @This()) @This() {
        return .{ .r = self.r + other.r };
    }
};

// Candidates as Figure

const FigureOfRect = impl(Figure).using(Rect);
const FigureOfCircle = impl(Figure).using(Circle);

// Methods called on implemented Figures

fn area(comptime Impl: type, s: ImplOf(Figure)(Impl)) f64 {
    return s.impl.surface(s.self);
}

fn add(comptime Impl: type, s: ImplOf(Figure)(Impl)) type {
    return impl(Figure).using(Impl).init(s.impl.add(s.self, s.self));
}

test "should computes area" {
    const r = FigureOfRect.init(.{ .w = 2, .h = 3 });
    const c = FigureOfCircle.init(.{ .r = 2 });

    try std.testing.expectEqual(
        @as(f64, 6),
        r.open(f64)(area),
    );
    try std.testing.expectEqual(
        @as(f64, std.math.pi * 2 * 2),
        c.open(f64)(area),
    );
}

test "should add itself and computes area" {
    const r = FigureOfRect.init(.{ .w = 2, .h = 3 });
    const c = FigureOfCircle.init(.{ .r = 2 });

    try std.testing.expectEqual(
        @as(f64, 24),
        r.open(type)(add).open(f64)(area),
    );
    try std.testing.expectEqual(
        @as(f64, std.math.pi * 2 * 2 * 2 * 2),
        c.open(type)(add).open(f64)(area),
    );
}
