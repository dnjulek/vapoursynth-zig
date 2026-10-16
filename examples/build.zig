const std = @import("std");
const zon = @import("build.zig.zon");

//NOTE: read https://codeberg.org/ziglang/zig/src/branch/master/lib/init/build.zig

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/invert_example.zig"),
        .target = target,
        .optimize = optimize,
    });

    const options = b.addOptions();
    const version = try std.SemanticVersion.parse(zon.version);
    options.addOption(std.SemanticVersion, "version", version);
    mod.addOptions("zon", options);

    const lib = b.addLibrary(.{
        .name = "invert_example",
        .linkage = .dynamic,
        .root_module = mod,
    });

    const vapoursynth_dep = b.dependency("vapoursynth", .{
        .target = target,
        .optimize = optimize,
        // .vsapi4_minor = .minor_0, // if you want to use outdated vapoursynth
    });

    lib.root_module.addImport("vapoursynth", vapoursynth_dep.module("vapoursynth"));
    lib.root_module.link_libc = true;

    if (lib.root_module.optimize == .fast) {
        lib.root_module.strip = true;
    }

    b.installArtifact(lib);
}
