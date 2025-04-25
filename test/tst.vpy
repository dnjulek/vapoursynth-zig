import vapoursynth as vs
core = vs.core
import os

path = "./zig-out/lib/libinvert_example.so" if (os.name == "posix")  else "./zig-out/bin/invert_example.dll"
core.std.LoadPlugin(path)


src = core.std.BlankClip(format=vs.YUV420P8, width=640, height=480, length=10, fpsnum=1, fpsden=1)

path_list = [
    "./zig-out/lib/libinvert_example.so",
    "./zig-out/bin/invert_example.dll",
    "./zig-out/lib/libinvert_example.dylib",
    "./zig-out/lib/libinvert_example.dylib",
]

zz = src.zinvert.Filter(enabled=True, prop="string_test", path=path_list)

props = zz.get_frame(0).props
assert(props._Transfer == vs.TRANSFER_LOG_316)
print(props)

zz.set_output()


# clear && zig build && vspipe -p ./tst.vpy .