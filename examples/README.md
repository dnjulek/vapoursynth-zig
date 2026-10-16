# invert_example

The example's [build.zig.zon](/examples/build.zig.zon) uses `.path = "../"`
to build the bindings from this checkout, including when CI builds the example.

To use this module in a separate project, run this from your project's directory
to add a pinned dependency to `build.zig.zon`:

```sh
zig fetch --save git+https://github.com/dnjulek/vapoursynth-zig.git
```

Then add these lines to your [build.zig](/examples/build.zig):

```zig
const vapoursynth_dep = b.dependency("vapoursynth", .{
    .target = target,
    .optimize = optimize,
});

lib.root_module.addImport("vapoursynth", vapoursynth_dep.module("vapoursynth"));
```

The [invert_example.zig](/examples/src/invert_example.zig) is based on [invert_example.c](https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c), from the VapourSynth SDK, I recommend checking it out first if you don't know the framework.

## Building
Zig version should be the ``minimum_zig_version`` in [build.zig.zon](/examples/build.zig.zon).

``zig build -Doptimize=fast``
