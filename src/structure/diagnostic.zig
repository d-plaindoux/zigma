const validator = @import("validator.zig");

pub fn report(diagnostic: validator.Error) void {
    switch (diagnostic) {
        .NotAStruct => |e| @compileError("Signature error: the type is a '" ++ @typeName(e.given) ++ "' and not a struct { ... } "),
        .FieldNotFound => |e| @compileError("Signature error: the function '" ++ e.name ++ "' is missing in " ++ @typeName(e.given)),
        .FieldTypeNotConform => |e| @compileError("Signature error for '" ++ e.name ++ "' in " ++ @typeName(e.impl) ++ ".\n" ++
            "  Expected: " ++ @typeName(e.expect) ++ "\n" ++
            "  Got     : " ++ @typeName(e.given)),
    }
}
