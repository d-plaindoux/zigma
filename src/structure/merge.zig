const std = @import("std");
const Validator = @import("validator.zig");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

const StructField = std.builtin.Type.StructField;

pub fn merge(comptime T1: type) type {
    return struct {
        pub fn with(comptime T2: type) type {
            var diagnostic: Diagnostic = undefined;
            Validator.isStruct(T1, &diagnostic) catch diagnostic.report();
            Validator.isStruct(T2, &diagnostic) catch diagnostic.report();

            const info1 = @typeInfo(T1);
            const info2 = @typeInfo(T2);

            const total_len = info1.@"struct".fields.len + info2.@"struct".fields.len;

            const data = comptime @"return": {
                var names: [total_len][]const u8 = undefined;
                var types: [total_len]type = undefined;
                var attributes: [total_len]StructField.Attributes = undefined;

                for (info1.@"struct".fields, 0..) |field, i| {
                    names[i] = field.name;
                    types[i] = field.type;
                    attributes[i] = .{
                        .@"align" = field.alignment,
                        .default_value_ptr = field.default_value_ptr,
                    };
                }

                for (info2.@"struct".fields, 0..) |field, i| {
                    const idx = info1.@"struct".fields.len + i;
                    names[idx] = field.name;
                    types[idx] = field.type;
                    attributes[idx] = .{
                        .@"align" = field.alignment,
                        .default_value_ptr = field.default_value_ptr,
                    };
                }

                break :@"return" .{
                    .names = names,
                    .types = types,
                    .attributes = attributes,
                };
            };

            return @Struct(
                .auto,
                null,
                &data.names,
                &data.types,
                &data.attributes,
            );
        }
    };
}
