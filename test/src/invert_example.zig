//! https://github.com/vapoursynth/vapoursynth/blob/master/sdk/invert_example.c

const std = @import("std");
const math = std.math;

const vapoursynth = @import("vapoursynth");
const vs = vapoursynth.vapoursynth4;
const vsh = vapoursynth.vshelper;
const vsc = vapoursynth.vsconstants;
const ZAPI = vapoursynth.ZAPI;
const zon = @import("zon");

// https://ziglang.org/documentation/master/#Choosing-an-Allocator
const allocator = std.heap.c_allocator;

const InvertData = struct {
    node: *vs.Node,
    vi: *const vs.VideoInfo,
    enabled: bool,
    path: [][]const u8 = undefined,
};

fn invertGetFrame(n: c_int, activation_reason: vs.ActivationReason, instance_data: ?*anyopaque, frame_data: ?*?*anyopaque, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.c) ?*const vs.Frame {
    _ = frame_data;
    const d: *InvertData = @ptrCast(@alignCast(instance_data));
    const zapi = ZAPI.init(vsapi, core, frame_ctx);

    if (activation_reason == .Initial) {
        zapi.requestFrameFilter(n, d.node);
    } else if (activation_reason == .AllFramesReady) {
        const src = zapi.initZFrame(d.node, n);
        defer src.deinit();
        const dst = src.newVideoFrame();

        const src2 = zapi.initZFrameFromVi(d.vi, null);

        const src_prop = src.getPropertiesRO();
        const dst_prop = dst.getPropertiesRW();

        const prop_example: vsc.MatrixCoefficient = src_prop.getMatrix();
        dst_prop.setInt("prop_example", @intFromEnum(prop_example), .Replace);

        std.debug.assert(src_prop.getCombed() == null);
        std.debug.assert(src_prop.getPictType() == null);

        dst_prop.setMatrix(.BT709);
        dst_prop.setPrimaries(.BT709);
        dst_prop.setChromaLocation(.TOP_LEFT);
        dst_prop.setColorRange(.LIMITED);
        dst_prop.setFieldBased(.PROGRESSIVE);
        dst_prop.setCombed(false);
        dst_prop.setField(1);
        dst_prop.setSARNum(1);
        dst_prop.setSARDen(1);
        dst_prop.setDurationNum(1);
        dst_prop.setDurationDen(1);
        dst_prop.setSceneChangeNext(true);
        dst_prop.setSceneChangePrev(false);
        dst_prop.setPictType("I");
        dst_prop.setTransfer(.LOG_316);

        std.debug.assert(dst_prop.getMatrix() == .BT709);
        std.debug.assert(dst_prop.getPrimaries() == .BT709);
        std.debug.assert(dst_prop.getTransfer() == .LOG_316);
        std.debug.assert(dst_prop.getChromaLocation().? == .TOP_LEFT);
        std.debug.assert(dst_prop.getColorRange().? == .LIMITED);
        std.debug.assert(dst_prop.getFieldBased().? == .PROGRESSIVE);
        std.debug.assert(dst_prop.getCombed().? == false);
        std.debug.assert(dst_prop.getField().? == 1);
        std.debug.assert(dst_prop.getSARNum().? == 1);
        std.debug.assert(dst_prop.getSARDen().? == 1);
        std.debug.assert(dst_prop.getDurationNum().? == 1);
        std.debug.assert(dst_prop.getDurationDen().? == 1);
        std.debug.assert(dst_prop.getSceneChangeNext().? == true);
        std.debug.assert(dst_prop.getSceneChangePrev().? == false);
        std.debug.assert(std.mem.eql(u8, dst_prop.getPictType().?, "I"));

        src.newVideoFrame2(.{ true, true, true }).deinit();
        src.newVideoFrame3(.{}).deinit();

        std.debug.assert(src.getStride2(u8, 0) == src.getStride(0));
        const dim2 = src.getDimensions2(u8, 0);
        std.debug.assert(src.getReadSlice2(u8, 0).len == dim2[1] * dim2[2]);
        const dim3 = src.getDimensions3(0);
        std.debug.assert(dim3.width == src.getWidth(0) and dim3.height == src.getHeight(0) and dim3.stride == src.getStride(0));

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

        dst_prop.consumeAlpha(src2.frame);

        return dst.frame;
    }

    return null;
}

fn invertFree(instance_data: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.c) void {
    _ = core;
    const d: *InvertData = @ptrCast(@alignCast(instance_data));
    vsapi.?.freeNode.?(d.node);

    allocator.free(d.path);
    allocator.destroy(d);
}

const name = "Invert";

fn invertCreate(in: ?*const vs.Map, out: ?*vs.Map, _: ?*anyopaque, core: ?*vs.Core, vsapi: ?*const vs.API) callconv(.c) void {
    var d: InvertData = undefined;

    var print_buf = [_]u8{0} ** 512; // buffer for setError2
    const zapi = ZAPI.init(vsapi, core, null);
    const map_in = zapi.initZMap(in);
    const map_out = zapi.initZMap2(out, &print_buf);

    // getNodeVi returns a tuple with [vs.Node, vs.VideoInfo],
    // use getNodeVi2 if you want a struct.
    d.node, d.vi = map_in.getNodeVi("clip").?; // since "clip" is not optional, we can use “.?” here.

    if (!vsh.isConstantVideoFormat(d.vi) or (d.vi.format.sampleType != .Integer) or (d.vi.format.bitsPerSample != 8)) {
        map_out.setError("Invert: only constant format 8bit integer input supported");
        zapi.freeNode(d.node);
        return;
    }

    if (!vsh.areValidDimensions(&d.vi.format, d.vi.width, d.vi.height)) {
        map_out.setError("Invert: dimensions not valid for the subsampling");
        zapi.freeNode(d.node);
        return;
    }

    // https://ziglang.org/documentation/master/#Optionals
    const enabled = map_in.getValue(i32, "enabled") orelse 1;

    if ((enabled < 0) or (enabled > 1)) {
        map_out.setError2("{s}: enabled must be {} or {}", .{ name, 0, 1 });
        zapi.freeNode(d.node);
        return;
    }

    d.enabled = enabled == 1;

    d.path = map_in.getDataArray("path", allocator).?;

    std.debug.print("path_0: {s}\n", .{d.path[0]});
    std.debug.print("path_1: {s}\n", .{d.path[1]});
    std.debug.print("path_2: {s}\n", .{d.path[2]});

    const prop = map_in.getData("prop", 0) orelse "empty";
    std.debug.print("prop in: {s}\n", .{prop});

    {
        const scratch = zapi.createZMap();
        defer scratch.free();
        scratch.setIntArray("ints", &.{ 1, 2, 3 });
        scratch.setFloatArray("floats", &.{ 1.5, 2.5 });
        std.debug.assert(scratch.numKeys() == 2);
        std.debug.assert(scratch.getType("ints") == .Int);
        const ints = scratch.getIntArray("ints").?;
        std.debug.assert(ints.len == 3 and ints[2] == 3);
        const floats = scratch.getFloatArray("floats").?;
        std.debug.assert(floats.len == 2 and floats[1] == 2.5);
        std.debug.assert(scratch.getValue(i64, "ints").? == 1);
        std.debug.assert(scratch.getValue(f64, "floats").? == 1.5);
        std.debug.assert(scratch.getBool("ints").? == true);
    }

    const data: *InvertData = allocator.create(InvertData) catch unreachable;
    data.* = d;

    var dep = [_]vs.FilterDependency{
        .{ .source = d.node, .requestPattern = .StrictSpatial },
    };

    zapi.createVideoFilter(out, name, d.vi, invertGetFrame, invertFree, .Parallel, &dep, data);
}

export fn VapourSynthPluginInit2(plugin: *vs.Plugin, vspapi: *const vs.PLUGINAPI) void {
    ZAPI.Plugin.config("com.example.zinvert", "zinvert", "VapourSynth Invert Example", zon.version, plugin, vspapi);
    ZAPI.Plugin.function("Filter", "clip:vnode;enabled:int:opt;prop:data:opt;path:data[]:opt;", "clip:vnode;", invertCreate, plugin, vspapi);
}
