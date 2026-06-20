const std = @import("std");
const curry = @import("zigma").functional.curry;

fn add2(a: u32, b: u32) u32 {
    return a + b;
}

test "currying add2 function" {
    const add: fn (u32) fn (u32) u32 = curry(add2);

    try std.testing.expectEqual(3, add(2)(1));
}

test "currying &add2 function" {
    const add = curry(&add2);

    try std.testing.expectEqual(3, add(2)(1));
}

fn add3(a: u32, b: u32, c: u32) u32 {
    return a + b + c;
}

test "currying add3 function" {
    const add = curry(add3);

    try std.testing.expectEqual(6, add(3)(2)(1));
}

test "currying &add3 function" {
    const add = curry(&add3);

    try std.testing.expectEqual(6, add(3)(2)(1));
}

fn add4(a: u32, b: u32, c: u32, d: u32) u32 {
    return a + b + c + d;
}

test "currying add4 function" {
    const add = curry(add4);

    try std.testing.expectEqual(10, add(4)(3)(2)(1));
}

test "currying &add4 function" {
    const add = curry(&add4);

    try std.testing.expectEqual(10, add(4)(3)(2)(1));
}
