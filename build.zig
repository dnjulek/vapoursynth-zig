const std = @import("std");

pub const VSAPI4 = enum(i32) {
    minor_0 = 0,
    minor_1 = 1,
};

pub const VSSAPI4 = enum(i32) {
    minor_1 = 1,
    minor_2 = 2,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vsapi4_minor: VSAPI4 = b.option(VSAPI4, "vsapi4_minor", "Set VapourSynth API4 minor") orelse .minor_1;
    const vssapi4_minor: VSSAPI4 = b.option(VSSAPI4, "vssapi4_minor", "Set VSScript API4 minor") orelse .minor_2;

    const options = b.addOptions();
    options.addOption(VSAPI4, "vsapi4_minor", vsapi4_minor);
    options.addOption(VSSAPI4, "vssapi4_minor", vssapi4_minor);
    const options_mod = options.createModule();

    const vapoursynth = b.addModule("vapoursynth", .{
        .root_source_file = b.path("src/module.zig"),
        .imports = &.{
            .{ .name = "build_options", .module = options_mod },
        },
    });

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/tests.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "vapoursynth", .module = vapoursynth },
            },
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run the binding unit tests");
    test_step.dependOn(&run_tests.step);
}
