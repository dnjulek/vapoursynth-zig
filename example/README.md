# invert_example

To use this module in your project you will need:
1. A [build.zig.zon](/example/build.zig.zon) file like this.
2. These lines in your [build.zig](/example/build.zig):

```zig
const vapoursynth_dep = b.dependency("vapoursynth", .{
    .target = target,
    .optimize = optimize,
});

lib.root_module.addImport("vapoursynth", vapoursynth_dep.module("vapoursynth"));
```

The [invert_example.zig](/example/src/invert_example.zig) is based on [invert_example.c](https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c), from the VapourSynth SDK, I recommend checking it out first if you don't know the framework.

## Building
Zig ver >= 0.12.0-dev.2058

``zig build -Doptimize=ReleaseFast``
