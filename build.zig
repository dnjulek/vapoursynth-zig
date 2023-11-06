const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    // Expose this as a module that others can import
    _ = b.addModule("vapoursynth", .{
        .source_file = .{ .path = "src/vapoursynth.zig" },
    });

    _ = b.addModule("vsconstants", .{
        .source_file = .{ .path = "src/vsconstants.zig" },
    });

    _ = b.addModule("vshelper", .{
        .source_file = .{ .path = "src/vshelper.zig" },
    });
}
