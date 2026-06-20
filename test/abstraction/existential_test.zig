const std = @import("std");
const Exists = @import("zigma").abstraction.Exists;

fn Identity(X: type) type {
    return X;
}

fn Opt(X: type) type {
    return ?X;
}

fn IsNotNull() type {
    return struct {
        pub fn run(X: type, value: Opt(X)) bool {
            return value != null;
        }
    };
}

test "should perform pack/unpack with optional values" {
    const Exists_i32 = Exists(Opt).pack(i32, null);

    try std.testing.expectEqual(false, Exists_i32.unpack(bool)(IsNotNull().run));
}
