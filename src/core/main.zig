///
///
///
///
const std = @import("std");

const Validator = struct {
    const ValidationErrorType = error{ZigmaError};

    const ValidationError = union(enum) {
        NotAStruct: struct { given: type },
        FieldNotFound: struct { name: []const u8, given: type },
        FieldTypeNotConform: struct { name: []const u8, impl: type, given: type, expect: type },
    };

    fn isStruct(comptime T: type, diagnostic: *ValidationError) ValidationErrorType!void {
        if (@typeInfo(T) != .@"struct") {
            diagnostic.* = .{
                .NotAStruct = .{
                    .given = T,
                },
            };
            return error.ZigmaError;
        }
    }

    fn fieldExists(
        comptime field: std.builtin.Type.StructField,
        comptime Impl: type,
        diagnostic: *ValidationError,
    ) ValidationErrorType!void {
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

    fn fieldHasType(
        comptime field: std.builtin.Type.StructField,
        comptime Impl: type,
        diagnostic: *ValidationError,
    ) ValidationErrorType!void {
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

    fn checkType(
        comptime Signature: type,
        comptime Impl: type,
        diagnostic: *ValidationError,
    ) ValidationErrorType!void {
        try isStruct(Signature, diagnostic);
        try isStruct(Impl, diagnostic);

        const Struct = @typeInfo(Signature).@"struct";

        inline for (Struct.fields) |field| {
            try fieldExists(field, Impl, diagnostic);
            try fieldHasType(field, Impl, diagnostic);
        }
    }
};

//
// Public corner
//

pub fn implement(comptime Spec: type) type {
    return struct {
        pub fn with(comptime Impl: type) Spec {
            var diagnostic: Validator.ValidationError = undefined;

            Validator.checkType(Spec, Impl, &diagnostic) catch switch (diagnostic) {
                .NotAStruct => |e| @compileError("Signature error: the type is a '" ++ @typeName(e.given) ++ "' and not a struct { ... } "),
                .FieldNotFound => |e| @compileError("Signature error: the function '" ++ e.name ++ "' is missing in " ++ @typeName(e.given)),
                .FieldTypeNotConform => |e| @compileError("Signature error for '" ++ e.name ++ "' in " ++ @typeName(e.impl) ++ ".\n" ++
                    "  Expected: " ++ @typeName(e.expect) ++ "\n" ++
                    "  Got     : " ++ @typeName(e.given)),
            };

            var result: Spec = undefined;

            inline for (@typeInfo(Spec).@"struct".fields) |field| {
                @field(result, field.name) = @field(Impl, field.name);
            }

            return result;
        }
    };
}
