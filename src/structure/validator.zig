const std = @import("std");
const StructField = std.builtin.Type.StructField;

pub const Error = union(enum) {
    const Type = error{ZigmaError};

    NotAStruct: struct { given: type },
    FieldNotFound: struct { name: []const u8, given: type },
    FieldTypeNotConform: struct { name: []const u8, impl: type, given: type, expect: type },
};

pub fn containsType(comptime Signature: type, comptime Impl: type, comptime diagnostic: *Error) Error.Type!void {
    try isStruct(Signature, diagnostic);
    try isStruct(Impl, diagnostic);

    inline for (@typeInfo(Signature).@"struct".fields) |field| {
        try fieldExists(field, Impl, diagnostic);
        try fieldHasType(field, Impl, diagnostic);
    }
}

pub fn isStruct(comptime T: type, diagnostic: *Error) Error.Type!void {
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

fn fieldExists(comptime field: StructField, comptime Impl: type, comptime diagnostic: *Error) Error.Type!void {
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

fn fieldHasType(comptime field: StructField, comptime Impl: type, comptime diagnostic: *Error) Error.Type!void {
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
