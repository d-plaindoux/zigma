const std = @import("std");

const notAFunction = "Argument should be a function or a function pointer";
const expectParameters = "Argument should be a function with 1 to 4 parameters";

fn FunType(comptime T: type, comptime acceptPointer: bool) ?std.builtin.Type.Fn {
    return switch (@typeInfo(T)) {
        .@"fn" => |info| info,
        .pointer => |info| if (acceptPointer) FunType(info.child, false) else null,
        else => null,
    };
}

fn Curry(comptime f: anytype) type {
    const T = FunType(@TypeOf(f), true) orelse @compileError(notAFunction);
    const arity = T.param_attrs.len;

    return switch (arity) {
        1 => fn (T.param_types[0].?) T.return_type.?,
        2 => fn (T.param_types[0].?) fn (T.param_types[1].?) T.return_type.?,
        3 => fn (T.param_types[0].?) fn (T.param_types[1].?) fn (T.param_types[2].?) T.return_type.?,
        4 => fn (T.param_types[0].?) fn (T.param_types[1].?) fn (T.param_types[2].?) fn (T.param_types[3].?) T.return_type.?,
        else => @compileError(expectParameters),
    };
}

// f : (A,B,...) -> R
pub fn curry(comptime f: anytype) Curry(f) {
    const T = FunType(@TypeOf(f), true) orelse @compileError(notAFunction);
    const arity = T.param_attrs.len;

    return switch (arity) {
        1 => f,
        2 => struct {
            const A = T.param_types[0].?;
            const B = T.param_types[1].?;
            const R = T.return_type.?;

            fn fun(a: A) fn (B) R {
                return struct {
                    fn fun(b: B) R {
                        return f(a, b);
                    }
                }.fun;
            }
        }.fun,
        3 => struct {
            const A = T.param_types[0].?;
            const B = T.param_types[1].?;
            const C = T.param_types[2].?;
            const R = T.return_type.?;

            fn fun(a: A) fn (B) fn (C) R {
                return curry(struct {
                    fn fun(b: B, c: C) R {
                        return f(a, b, c);
                    }
                }.fun);
            }
        }.fun,
        4 => struct {
            const A = T.param_types[0].?;
            const B = T.param_types[1].?;
            const C = T.param_types[2].?;
            const D = T.param_types[3].?;
            const R = T.return_type.?;

            fn fun(a: A) fn (B) fn (C) fn (D) R {
                return curry(struct {
                    fn fun(b: B, c: C, d: D) R {
                        return f(a, b, c, d);
                    }
                }.fun);
            }
        }.fun,
        else => @compileError(notAFunction),
    };
}

fn add2(a: u32, b: u32) u32 {
    return a + b;
}

test "currying add2 function" {
    const add: fn (u32) fn(u32) u32 = curry(add2);

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
