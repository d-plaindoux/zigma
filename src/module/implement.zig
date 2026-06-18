const Validator = @import("validator.zig");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

pub fn implement(comptime Spec: type) type {
    return struct {
        pub fn using(comptime Impl: type) Spec {
            var diagnostic: Diagnostic = undefined;

            Validator.containsSpecs(Spec, Impl, &diagnostic) catch diagnostic.report();

            comptime {
                var result: Spec = undefined;

                for (@typeInfo(Spec).@"struct".fields) |field| {
                    @field(result, field.name) = @field(Impl, field.name);
                }

                return result;
            }
        }
    };
}
