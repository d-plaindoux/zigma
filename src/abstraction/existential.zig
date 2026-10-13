// /!\ This code can be called only during compilation

// Cont : ∀y. ∀x. T(x) -> y
fn Cont(comptime T: fn (type) type, comptime Y: type) type {
    const inner = struct {
        fn run(comptime X: type, _: T(X)) Y {
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
                pub fn open(comptime Y: type) fn (Cont(T, Y)) Y {
                    return struct {
                        fn run(cont: Cont(T, Y)) Y {
                            return cont(X, value);
                        }
                    }.run;
                }
            };
        }
    };
}
