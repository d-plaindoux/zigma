const std = @import("std");
const Validator = @import("validator.zig");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

pub fn combine(comptime T1: type, T2: type) type {
    var diagnostic: Diagnostic = undefined;
    Validator.isStruct(T1, &diagnostic) catch diagnostic.report();
    Validator.isStruct(T2, &diagnostic) catch diagnostic.report();

    const info1 = @typeInfo(T1);
    const info2 = @typeInfo(T2);

    const total_len = info1.@"struct".field_names.len + info2.@"struct".field_names.len;

    const data = comptime @"return": {
        var names: [total_len][]const u8 = undefined;
        var types: [total_len]type = undefined;
        var attributes: [total_len]std.lang.Type.Struct.FieldAttributes = undefined;

        for (0..info1.@"struct".field_names.len) |i| {
            names[i] = info1.@"struct".field_names[i];
            types[i] = info1.@"struct".field_types[i];
            attributes[i] = .{
                .@"align" = info1.@"struct".field_attrs[i].@"align",
                .default_value_ptr = info1.@"struct".field_attrs[i].default_value_ptr,
            };
        }

        for (0..info2.@"struct".field_names.len) |i| {
            const idx = info1.@"struct".field_names.len + i;
            names[idx] = info2.@"struct".field_names[i];
            types[idx] = info2.@"struct".field_types[i];
            attributes[idx] = .{
                .@"align" = info2.@"struct".field_attrs[i].@"align",
                .default_value_ptr = info2.@"struct".field_attrs[i].default_value_ptr,
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
