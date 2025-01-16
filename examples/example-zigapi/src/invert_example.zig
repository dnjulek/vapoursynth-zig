//! https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c

const std = @import("std");
const vapoursynth = @import("vapoursynth");

const math = std.math;
const vs = vapoursynth.vapoursynth4;
const vsh = vapoursynth.vshelper;
const zapi = vapoursynth.zigapi;

// https://ziglang.org/documentation/master/#Choosing-an-Allocator
const allocator = std.heap.c_allocator;

const InvertData = struct {
    node: ?*vs.Node,
    vi: *const vs.VideoInfo,
    enabled: bool,
};

export fn invertGetFrame(n: c_int, activation_reason: vs.ActivationReason, instance_data: ?*anyopaque, frame_data: ?*?*anyopaque, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) ?*const vs.Frame {
    _ = frame_data;
    const d: *InvertData = @ptrCast(@alignCast(instance_data));

    if (activation_reason == .Initial) {
        vsapi.?.requestFrameFilter.?(n, d.node, frame_ctx);
    } else if (activation_reason == .AllFramesReady) {
        var src = zapi.ZFrame.init(d.node, n, frame_ctx, core, vsapi);
        defer src.deinit();
        var dst = src.newVideoFrame();

        const src_prop = src.getProperties();
        const dst_prop = dst.getProperties();
        const prop_example = src_prop.getInt(i32, "_Matrix") orelse 2;
        dst_prop.setInt("prop_example", prop_example, .Replace);

        var plane: u32 = 0;
        while (plane < d.vi.format.numPlanes) : (plane += 1) {
            var srcp = src.getReadSlice(plane);
            var dstp = dst.getWriteSlice(plane);

            // getDimensions returns a tuple with [width, height, stride],
            // use getDimensions2 if you want a struct.
            const w, const h, const stride = src.getDimensions(plane);

            var y: u32 = 0;
            while (y < h) : (y += 1) {
                var x: u32 = 0;
                while (x < w) : (x += 1) {
                    dstp[x] = if (d.enabled) ~(srcp[x]) else srcp[x];
                }

                dstp = dstp[stride..];
                srcp = srcp[stride..];
            }
        }

        return dst.frame;
    }

    return null;
}

export fn invertFree(instance_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = core;
    const d: *InvertData = @ptrCast(@alignCast(instance_data));
    vsapi.?.freeNode.?(d.node);
    allocator.destroy(d);
}

export fn invertCreate(in: ?*const vs.Map, out: ?*vs.Map, user_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = user_data;
    var d: InvertData = undefined;
    const map_in = zapi.ZMap.init(in, vsapi);
    const map_out = zapi.ZMap.init(out, vsapi);

    // getNodeVi returns a tuple with [vs.Node, vs.VideoInfo],
    // use getNodeVi2 if you want a struct.
    d.node, d.vi = map_in.getNodeVi("clip");

    if (!vsh.isConstantVideoFormat(d.vi) or (d.vi.format.sampleType != .Integer) or (d.vi.format.bitsPerSample != 8)) {
        map_out.setError("Invert: only constant format 8bit integer input supported");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    // https://ziglang.org/documentation/master/#Optionals
    const enabled = map_in.getInt(i32, "enabled") orelse 1;

    if ((enabled < 0) or (enabled > 1)) {
        map_out.setError("Invert: enabled must be 0 or 1");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    d.enabled = enabled == 1;

    const data: *InvertData = allocator.create(InvertData) catch unreachable;
    data.* = d;

    var deps = [_]vs.FilterDependency{
        vs.FilterDependency{
            .source = d.node,
            .requestPattern = .StrictSpatial,
        },
    };

    vsapi.?.createVideoFilter.?(out, "Invert", d.vi, invertGetFrame, invertFree, .Parallel, &deps, deps.len, data, core);
}

export fn VapourSynthPluginInit2(plugin: *vs.Plugin, vspapi: *const vs.PLUGINAPI) void {
    _ = vspapi.configPlugin.?("com.example.zinvert", "zinvert", "VapourSynth Invert Example", vs.makeVersion(1, 0), vs.VAPOURSYNTH_API_VERSION, 0, plugin);
    _ = vspapi.registerFunction.?("Filter", "clip:vnode;enabled:int:opt;", "clip:vnode;", invertCreate, null, plugin);
}
