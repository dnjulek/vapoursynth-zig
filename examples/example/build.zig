const std = @import("std");

pub const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 14, .patch = 0 };

pub fn build(b: *std.Build) void {
    ensureZigVersion() catch return;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "invert_example",
        .root_source_file = b.path("src/invert_example.zig"),
        .target = target,
        .optimize = optimize,
    });

    const vapoursynth_dep = b.dependency("vapoursynth", .{
        .target = target,
        .optimize = optimize,
      //.vsapi4_minor = .minor_0, // if you want to use outdated vapoursynth
    });

    lib.root_module.addImport("vapoursynth", vapoursynth_dep.module("vapoursynth"));
    lib.linkLibC();

    if (lib.root_module.optimize == .ReleaseFast) {
        lib.root_module.strip = true;
    }

    b.installArtifact(lib);
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
