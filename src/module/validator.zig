const std = @import("std");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

const StructField = std.builtin.Type.StructField;

pub inline fn containsSpecs(
    comptime Signature: type,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    try isStruct(Signature, diagnostic);
    try isStruct(Impl, diagnostic);

    inline for (0..@typeInfo(Signature).@"struct".field_names.len) |i| {
        try fieldExists(
            @typeInfo(Signature).@"struct".field_names[i],
            Impl,
            diagnostic,
        );
        try fieldHasType(
            @typeInfo(Signature).@"struct".field_names[i],
            @typeInfo(Signature).@"struct".field_types[i],
            Impl,
            diagnostic,
        );
    }
}

pub inline fn isStruct(comptime T: type, diagnostic: *Diagnostic) Diagnostic.Error!void {
    if (@typeInfo(T) != .@"struct") {
        diagnostic.* = .{
            .NotAStruct = .{
                .given = T,
            },
        };
        return error.ZigmaError;
    }
}

//
// Private corner
//

inline fn fieldExists(
    comptime field_name: [:0]const u8,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    if (!@hasDecl(Impl, field_name)) {
        diagnostic.* = .{
            .FieldNotFound = .{
                .name = field_name,
                .given = Impl,
            },
        };
        return error.ZigmaError;
    }
}

inline fn fieldHasType(
    comptime field_name: [:0]const u8,
    comptime field_type: type,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    const actual_type = @TypeOf(@field(Impl, field_name));
    if (actual_type != field_type) {
        diagnostic.* = .{
            .FieldTypeNotConform = .{
                .name = field_name,
                .impl = Impl,
                .expect = field_type,
                .given = actual_type,
            },
        };
        return error.ZigmaError;
    }
}
