const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = b.standardOptimizeOption(.{}),
        .target = b.standardTargetOptions(.{}),
    });

    const exe = b.addExecutable(.{
        .name = "scop",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");

    run_step.dependOn(&run_cmd.step);
}
