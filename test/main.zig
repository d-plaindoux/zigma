pub const curry = @import("functional/curry_test.zig");
pub const existential = @import("abstraction/existential_test.zig");
pub const implement = @import("module/implement_nominal_test.zig");
pub const implement_OO = @import("module/implement_nominal_OO_test.zig");
pub const merge = @import("module/merge_nominal_test.zig");
test {
    @import("std").testing.refAllDecls(@This());
}
