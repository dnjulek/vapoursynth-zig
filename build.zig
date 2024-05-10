const std = @import("std");

pub const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 13, .patch = 0, .pre = "dev.133" };

pub fn build(b: *std.Build) void {
    ensureZigVersion() catch return;

    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    // Expose this as a module that others can import
    _ = b.addModule("vapoursynth", .{
        .root_source_file = b.path("src/module.zig"),
    });
}

fn ensureZigVersion() !void {
    var installed_ver = @import("builtin").zig_version;
    installed_ver.build = null;

    if (installed_ver.order(min_zig_version) == .lt) {
        std.log.err("\n" ++
            \\---------------------------------------------------------------------------
            \\
            \\Installed Zig compiler version is too old.
            \\
            \\Min. required version: {any}
            \\Installed version: {any}
            \\
            \\Please install newer version and try again.
            \\Latest version can be found here: https://ziglang.org/download/
            \\
            \\---------------------------------------------------------------------------
            \\
        , .{ min_zig_version, installed_ver });
        return error.ZigIsTooOld;
    }
}
