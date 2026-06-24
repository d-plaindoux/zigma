// ∃x. T(x) = ∀y. (∀x. T(x) -> y) -> y
pub fn Exists(comptime T: fn (type) type) type {
    return struct {
        pub fn pack(comptime X: type, value: T(X)) type {
            return struct {
                pub fn unpack(comptime Y: type, comptime cont: anytype) Y {
                    return cont(X, value);
                }
            };
        }
    };
}

// Only valid during compilation stage !
