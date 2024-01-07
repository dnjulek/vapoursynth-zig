const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    // Expose this as a module that others can import
    _ = b.addModule("vapoursynth", .{
        .root_source_file = .{ .path = "src/module.zig" },
    });
}
