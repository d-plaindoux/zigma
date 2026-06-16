const std = @import("std");
const Diagnostic = @import("diagnostic.zig").Diagnostic;

const StructField = std.builtin.Type.StructField;

pub inline fn containsType(
    comptime Signature: type,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    try isStruct(Signature, diagnostic);
    try isStruct(Impl, diagnostic);

    inline for (@typeInfo(Signature).@"struct".fields) |field| {
        try fieldExists(field, Impl, diagnostic);
        try fieldHasType(field, Impl, diagnostic);
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
    comptime field: StructField,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    if (!@hasDecl(Impl, field.name)) {
        diagnostic.* = .{
            .FieldNotFound = .{
                .name = field.name,
                .given = Impl,
            },
        };
        return error.ZigmaError;
    }
}

inline fn fieldHasType(
    comptime field: StructField,
    comptime Impl: type,
    comptime diagnostic: *Diagnostic,
) Diagnostic.Error!void {
    const actual_type = @TypeOf(@field(Impl, field.name));
    if (actual_type != field.type) {
        diagnostic.* = .{
            .FieldTypeNotConform = .{
                .name = field.name,
                .impl = Impl,
                .expect = field.type,
                .given = actual_type,
            },
        };
        return error.ZigmaError;
    }
}
