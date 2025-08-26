# invert_example

To use this module in your project you will need:
1. A [build.zig.zon](/examples/build.zig.zon) file like this.
2. These lines in your [build.zig](/examples/build.zig):

```zig
const vapoursynth_dep = b.dependency("vapoursynth", .{
    .target = target,
    .optimize = optimize,
});

lib.root_module.addImport("vapoursynth", vapoursynth_dep.module("vapoursynth"));
```

To update the .zon file run:\
``zig fetch --save git+https://github.com/dnjulek/vapoursynth-zig.git``

The [invert_example.zig](/examples/src/invert_example.zig) is based on [invert_example.c](https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c), from the VapourSynth SDK, I recommend checking it out first if you don't know the framework.

## Building
Zig version should be the ``minimum_zig_version`` in [build.zig.zon](/examples/build.zig.zon).

``zig build -Doptimize=ReleaseFast``
