const std = @import("std");

pub fn build(b: *std.Build) void {
    const zigma = b.addModule(
        "zigma",
        .{
            .root_source_file = b.path("src/zigma.zig"),
            .target = b.graph.host,
        },
    );

    //
    // Test corner
    //

    const test_step = b.step("test", "Tests execution");

    {
        const tests = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path("test/zigma_nominal_test.zig"),
                .target = b.graph.host,
            }),
        });

        tests.root_module.addImport("zigma", zigma);
        const run = b.addRunArtifact(tests);
        test_step.dependOn(&run.step);
    }

    // Compilation failures

    if (false) { // Still in progress here
        const tests = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path("test/zigma_failing_test.zig"),
                .target = b.graph.host,
            }),
        });

        tests.root_module.addImport("zigma", zigma);
        const run = b.addRunArtifact(tests);
        run.expectExitCode(1);
        run.expectStdErrEqual("TODO");
        test_step.dependOn(&run.step);
    }
}
