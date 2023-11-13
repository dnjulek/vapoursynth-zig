//! https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c

const std = @import("std");
const vapoursynth = @import("vapoursynth");

const math = std.math;
const vs = vapoursynth.vapoursynth4;
const vsh = vapoursynth.vshelper;

const ar = vs.ActivationReason;
const rp = vs.RequestPattern;
const fm = vs.FilterMode;
const st = vs.SampleType;

// https://ziglang.org/documentation/master/#Choosing-an-Allocator
const allocator = std.heap.c_allocator;

const InvertData = struct {
    node: ?*vs.Node,
    enabled: bool,
};

export fn invertGetFrame(n: c_int, activation_reason: ar, instance_data: ?*anyopaque, frame_data: ?*?*anyopaque, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) ?*const vs.Frame {
    _ = frame_data;
    var d: *InvertData = @ptrCast(@alignCast(instance_data));

    if (activation_reason == ar.Initial) {
        vsapi.?.requestFrameFilter.?(n, d.node, frame_ctx);
    } else if (activation_reason == ar.AllFramesReady) {
        const src = vsapi.?.getFrameFilter.?(n, d.node, frame_ctx);

        // https://ziglang.org/documentation/master/#defer
        defer vsapi.?.freeFrame.?(src);

        const fi = vsapi.?.getVideoFrameFormat.?(src);

        const height = vsapi.?.getFrameHeight.?(src, 0);
        const width = vsapi.?.getFrameWidth.?(src, 0);
        var dst = vsapi.?.newVideoFrame.?(fi, width, height, src, core);

        var plane: c_int = 0;
        while (plane < fi.numPlanes) : (plane += 1) {
            var srcp: [*]const u8 = vsapi.?.getReadPtr.?(src, plane);
            var dstp: [*]u8 = vsapi.?.getWritePtr.?(dst, plane);
            const stride: usize = @intCast(vsapi.?.getStride.?(src, plane));
            const h: usize = @intCast(vsapi.?.getFrameHeight.?(src, plane));
            const w: usize = @intCast(vsapi.?.getFrameWidth.?(src, plane));

            var y: usize = 0;
            while (y < h) : (y += 1) {
                var x: usize = 0;
                while (x < w) : (x += 1) {
                    dstp[x] = if (d.enabled) ~(srcp[x]) else srcp[x];
                }

                dstp += stride;
                srcp += stride;
            }
        }

        return dst;
    }

    return null;
}

export fn invertFree(instance_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = core;
    var d: *InvertData = @ptrCast(@alignCast(instance_data));
    vsapi.?.freeNode.?(d.node);
    allocator.destroy(d);
}

export fn invertCreate(in: ?*const vs.Map, out: ?*vs.Map, user_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.C) void {
    _ = user_data;
    var d: InvertData = undefined;
    var err: c_int = undefined;

    d.node = vsapi.?.mapGetNode.?(in, "clip", 0, &err).?;
    var vi: *const vs.VideoInfo = vsapi.?.getVideoInfo.?(d.node);

    if (!vsh.isConstantVideoFormat(vi) or (vi.format.sampleType != st.Integer) or (vi.format.bitsPerSample != @as(c_int, 8))) {
        vsapi.?.mapSetError.?(out, "Invert: only constant format 8bit integer input supported");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    var enabled: i32 = undefined;
    // math.lossyCast = mapGetIntSaturated or vsh_int64ToIntS (same for float)
    enabled = math.lossyCast(i32, vsapi.?.mapGetInt.?(in, "enabled", 0, &err));
    if (err != 0) {
        enabled = 1;
    }

    if ((enabled < 0) or (enabled > 1)) {
        vsapi.?.mapSetError.?(out, "Invert: enabled must be 0 or 1");
        vsapi.?.freeNode.?(d.node);
        return;
    }

    d.enabled = enabled == 1;

    var data: *InvertData = allocator.create(InvertData) catch unreachable;
    data.* = d;

    var deps = [_]vs.FilterDependency{
        vs.FilterDependency{
            .source = d.node,
            .requestPattern = rp.StrictSpatial,
        },
    };

    vsapi.?.createVideoFilter.?(out, "Invert", vi, invertGetFrame, invertFree, fm.Parallel, &deps, deps.len, data, core);
}

export fn VapourSynthPluginInit2(plugin: *vs.Plugin, vspapi: *const vs.PLUGINAPI) void {
    _ = vspapi.configPlugin.?("com.example.invert", "invert", "VapourSynth Invert Example", vs.makeVersion(1, 0), vs.VAPOURSYNTH_API_VERSION, 0, plugin);
    _ = vspapi.registerFunction.?("Filter", "clip:vnode;enabled:int:opt;", "clip:vnode;", invertCreate, null, plugin);
}
