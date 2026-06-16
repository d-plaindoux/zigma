const validator = @import("validator.zig");
const diagnostic = @import("diagnostic.zig");

pub fn implement(comptime Spec: type) type {
    return struct {
        pub fn with(comptime Impl: type) Spec {
            var d: validator.Error = undefined;

            validator.containsType(Spec, Impl, &d) catch diagnostic.report(d);

            var result: Spec = undefined;

            inline for (@typeInfo(Spec).@"struct".fields) |field| {
                @field(result, field.name) = @field(Impl, field.name);
            }

            return result;
        }
    };
}
