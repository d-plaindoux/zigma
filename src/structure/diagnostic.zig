pub const Diagnostic = union(enum) {
    pub const Error = error{ZigmaError};

    NotAStruct: struct { given: type },
    FieldNotFound: struct { name: []const u8, given: type },
    FieldTypeNotConform: struct { name: []const u8, impl: type, given: type, expect: type },

    pub fn report(diagnostic: @This()) void {
        switch (diagnostic) {
            .NotAStruct => |e| {
                @compileError("Signature error: the type is a '" ++ @typeName(e.given) ++ "' and not a struct { ... } ");
            },
            .FieldNotFound => |e| {
                @compileError("Signature error: the function '" ++ e.name ++ "' is missing in " ++ @typeName(e.given));
            },
            .FieldTypeNotConform => |e| {
                @compileError("Signature error for '" ++ e.name ++ "' in " ++ @typeName(e.impl) ++ ".\n" ++
                    "  Expected: " ++ @typeName(e.expect) ++ "\n" ++
                    "  Got     : " ++ @typeName(e.given));
            },
        }
    }
};
