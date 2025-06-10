const std = @import("std");

pub const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 14, .patch = 0, .pre = "dev.3445" };

pub fn build(b: *std.Build) void {
    ensureZigVersion() catch return;

    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    const vs_use_api_41 = b.option(bool, "vs_use_api_41", "Use VapourSynth API 4.1") orelse false;
    const vs_use_latest_api = b.option(bool, "vs_use_latest_api", "Use Latest VapourSynth API") orelse false;
    const vsscript_use_api_42 = b.option(bool, "vsscript_use_api_42", "Use VSScript API 4.2") orelse false;
    const vsscript_use_latest_api = b.option(bool, "vsscript_use_latest_api", "Use Latest VSScript API") orelse false;

    // Create build options
    const options = b.addOptions();
    options.addOption(bool, "vs_use_api_41", vs_use_api_41);
    options.addOption(bool, "vs_use_latest_api", vs_use_latest_api);
    options.addOption(bool, "vsscript_use_api_42", vsscript_use_api_42);
    options.addOption(bool, "vsscript_use_latest_api", vsscript_use_latest_api);

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
