const std = @import("std");

const Exists = @import("zigma").abstraction.Exists;
const implement = @import("zigma").module.implement;

fn Opt(X: type) type {
    return ?X;
}

fn IsNotNull(comptime X: type, value: Opt(X)) bool {
    return value != null;
}

test "should perform pack/open with optional values" {
    const Exists_i32 = Exists(Opt).pack(i32, null);

    try std.testing.expectEqual(false, Exists_i32.open(bool)(IsNotNull));
}
