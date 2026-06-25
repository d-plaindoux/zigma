// Cont : ∀y. ∀x. T(x) -> y
fn Cont(T: fn (type) type, Y: type) type {
    const inner = struct {
        fn run(X: type, _: T(X)) Y {
            unreachable;
        }
    };
    return @TypeOf(inner.run);
}

// ∃x. T(x) = ∀y. (∀x. T(x) -> y) -> y
pub fn Exists(comptime T: fn (type) type) type {
    return struct {
        pub fn pack(comptime X: type, value: T(X)) type {
            return struct {
                pub fn unpack(comptime Y: type, comptime cont: Cont(T, Y)) Y {
                    return cont(X, value);
                }
            };
        }
    };
}
