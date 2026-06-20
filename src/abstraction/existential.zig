// ∃x. T(x) = ∀y. (∀x. T(x) -> y) -> y
pub fn Exists(comptime T: fn (type) type) type {
    return struct {
        pub fn pack(comptime X: type, value: T(X)) type {
            return struct {
                // Currified version in order to have a runtime vs comptime facet.
                pub fn unpack(comptime Y: type) fn (fn (T(X)) Y) Y {
                    return struct {
                        pub fn run(cont: fn (T(X)) Y) Y {
                            return cont(value);
                        }
                    }.run;
                }
            };
        }
    };
}
