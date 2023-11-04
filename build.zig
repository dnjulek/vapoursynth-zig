const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "vapoursynth",
        .root_source_file = .{ .path = "src/vapoursynth.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);
}
