import vapoursynth as vs
core = vs.core

#core.std.LoadPlugin("zig-out/bin/invert_example.dll")
core.std.LoadPlugin("./zig-out/lib/libinvert_example.so")


src = core.std.BlankClip(format=vs.YUV420P8, width=640, height=480, length=10, fpsnum=1, fpsden=1)

zz = src.zinvert.Filter(enabled=True)

props = zz.get_frame(0).props
assert(props._Transfer == vs.TRANSFER_LOG_316)
print(props)

zz.set_output()


# clear && zig build && vspipe -p ./tst.vpy .