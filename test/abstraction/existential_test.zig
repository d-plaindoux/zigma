const std = @import("std");
const Exists = @import("zigma").abstraction.Exists;

fn Identity(X: type) type {
    return X;
}

fn Opt(X: type) type {
    return ?X;
}

fn IsNotNull(X: type) fn (Opt(X)) bool {
    return struct {
        pub fn run(value: Opt(X)) bool {
            return value != null;
        }
    }.run;
}

test "should perform pack/unpack with optional values" {
    const Exists_i32 = Exists(Opt).pack(i32, null);

    try std.testing.expectEqual(false, Exists_i32.unpack(bool)(IsNotNull(i32)));
}
