const Validator = @import("validator.zig");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

pub fn implement(comptime Spec: type) type {
    return struct {
        pub fn using(comptime Impl: type) Spec {
            return comptime blk: {
                var diagnostic: Diagnostic = undefined;

                Validator.containsSpecs(Spec, Impl, &diagnostic) catch diagnostic.report();
                var result: Spec = undefined;

                for (0..@typeInfo(Spec).@"struct".field_names.len) |i| {
                    @field(result, @typeInfo(Spec).@"struct".field_names[i]) =
                        @field(Impl, @typeInfo(Spec).@"struct".field_names[i]);
                }

                break :blk result;
            };
        }
    };
}
