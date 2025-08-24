const std = @import("std");

pub const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 15, .patch = 1 };

pub const VSAPI4 = enum(i32) {
    minor_0 = 0,
    minor_1 = 1,
};

pub const VSSAPI4 = enum(i32) {
    minor_1 = 1,
    minor_2 = 2,
};

pub fn build(b: *std.Build) void {
    ensureZigVersion() catch return;

    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    const vsapi4_minor: VSAPI4 = b.option(VSAPI4, "vsapi4_minor", "Set VapourSynth API4 minor") orelse .minor_1;
    const vssapi4_minor: VSSAPI4 = b.option(VSSAPI4, "vssapi4_minor", "Set VSScript API4 minor") orelse .minor_2;

    // Create build options
    const options = b.addOptions();
    options.addOption(VSAPI4, "vsapi4_minor", vsapi4_minor);
    options.addOption(VSSAPI4, "vssapi4_minor", vssapi4_minor);

    // Expose this as a module that others can import
    _ = b.addModule("vapoursynth", .{
        .root_source_file = b.path("src/module.zig"),
        .imports = &.{
            .{ .name = "build_options", .module = options.createModule() },
        },
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
