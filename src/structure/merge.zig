const std = @import("std");
const validator = @import("validator.zig");
const diagnostic = @import("diagnostic.zig");
const StructField = std.builtin.Type.StructField;

/// Fonction exécutée à la compilation qui retourne un nouveau type
pub fn merge(comptime T1: type) type {
    return struct {
        pub fn with(comptime T2: type) type {
            var d: validator.Error = undefined;
            validator.isStruct(T1, &d) catch diagnostic.report(d);
            validator.isStruct(T2, &d) catch diagnostic.report(d);

            const info1 = @typeInfo(T1);
            const info2 = @typeInfo(T2);

            const total_len = info1.@"struct".fields.len + info2.@"struct".fields.len;

            var names: [total_len][]const u8 = undefined;
            var types: [total_len]type = undefined;
            var attributes: [total_len]StructField.Attributes = undefined;

            inline for (info1.@"struct".fields, 0..) |field, i| {
                names[i] = field.name;
                types[i] = field.type;
                attributes[i] = .{
                    .@"align" = field.alignment,
                    .default_value_ptr = field.default_value_ptr,
                };
            }

            inline for (info2.@"struct".fields, 0..) |field, i| {
                const idx = info1.@"struct".fields.len + i;
                names[idx] = field.name;
                types[idx] = field.type;
                attributes[idx] = .{
                    .@"align" = field.alignment,
                    .default_value_ptr = field.default_value_ptr,
                };
            }

            return @Struct(
                .auto,
                null,
                &names,
                &types,
                &attributes,
            );
        }
    };
}
