const std = @import("std");
const vs = @import("vapoursynth4.zig");
const math = std.math;

pub const ZFrame = struct {
    pub fn init(node: ?*vs.Node, n: c_int, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) ZFrameRO {
        return ZFrameRO.init(node, n, frame_ctx, core, vsapi);
    }
};

const ZFrameRO = struct {
    frame_ctx: ?*vs.FrameContext,
    core: ?*vs.Core,
    vsapi: ?*const vs.API,
    frame: ?*const vs.Frame,

    node: ?*vs.Node,
    n: c_int,

    const Self = @This();
    pub fn init(node: ?*vs.Node, n: c_int, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) Self {
        const frame = vsapi.?.getFrameFilter.?(n, node, frame_ctx);
        return .{
            .frame_ctx = frame_ctx,
            .core = core,
            .vsapi = vsapi,
            .frame = frame,
            .node = node,
            .n = n,
        };
    }

    pub fn deinit(self: *Self) void {
        self.vsapi.?.freeFrame.?(self.frame);
    }

    pub fn newVideoFrame(self: Self) ZFrameRW {
        const frame = self.vsapi.?.newVideoFrame.?(
            self.vsapi.?.getVideoFrameFormat.?(self.frame),
            self.vsapi.?.getFrameWidth.?(self.frame, 0),
            self.vsapi.?.getFrameHeight.?(self.frame, 0),
            self.frame,
            self.core,
        );

        return .{
            .frame_ctx = self.frame_ctx,
            .core = self.core,
            .vsapi = self.vsapi,
            .frame = frame,
            .ro = &self,
        };
    }

    pub fn newVideoFrame2(self: Self, process: [3]bool) ZFrameRW {
        var planes = [3]c_int{ 0, 1, 2 };
        var cp_planes = [3]?*const vs.Frame{
            if (process[0]) null else self.frame,
            if (process[1]) null else self.frame,
            if (process[2]) null else self.frame,
        };

        const frame = self.vsapi.?.newVideoFrame2.?(
            self.vsapi.?.getVideoFrameFormat.?(self.frame),
            self.vsapi.?.getFrameWidth.?(self.frame, 0),
            self.vsapi.?.getFrameHeight.?(self.frame, 0),
            &cp_planes,
            &planes,
            self.frame,
            self.core,
        );

        return .{
            .frame_ctx = self.frame_ctx,
            .core = self.core,
            .vsapi = self.vsapi,
            .frame = frame,
            .ro = &self,
        };
    }

    pub fn newVideoFrame3(self: Self, width: u32, height: u32) ZFrameRW {
        const frame = self.vsapi.?.newVideoFrame.?(
            self.vsapi.?.getVideoFrameFormat.?(self.frame),
            @intCast(width),
            @intCast(height),
            self.frame,
            self.core,
        );

        return .{
            .frame_ctx = self.frame_ctx,
            .core = self.core,
            .vsapi = self.vsapi,
            .frame = frame,
            .ro = &self,
        };
    }

    pub fn copyFrame(self: Self) ZFrameRW {
        return .{
            .frame_ctx = self.frame_ctx,
            .core = self.core,
            .vsapi = self.vsapi,
            .frame = self.vsapi.?.copyFrame.?(self.frame, self.core),
            .ro = &self,
        };
    }

    pub fn getHeight(self: Self, plane: usize) u32 {
        return @intCast(self.vsapi.?.getFrameHeight.?(self.frame, @intCast(plane)));
    }

    pub fn getWidth(self: Self, plane: usize) u32 {
        return @intCast(self.vsapi.?.getFrameWidth.?(self.frame, @intCast(plane)));
    }

    pub fn getStride(self: Self, plane: usize) u32 {
        return @intCast(self.vsapi.?.getStride.?(self.frame, @intCast(plane)));
    }

    pub fn getDimensions(self: Self, plane: usize) struct { u32, u32, u32 } {
        return .{ self.getWidth(plane), self.getHeight(plane), self.getStride(plane) };
    }

    pub fn getReadSlice(self: Self, plane: usize) []const u8 {
        const ptr = self.vsapi.?.getReadPtr.?(self.frame, @intCast(plane));
        const len = self.getHeight(plane) * self.getStride(plane);
        return ptr[0..len];
    }

    pub fn getStride2(self: Self, comptime T: type, plane: usize) u32 {
        return @intCast(self.vsapi.?.getStride.?(self.frame, @intCast(plane)) >> (@sizeOf(T) >> 1));
    }

    pub fn getDimensions2(self: Self, comptime T: type, plane: usize) struct { u32, u32, u32 } {
        return .{ self.getWidth(plane), self.getHeight(plane), self.getStride2(T, plane) };
    }

    pub fn getReadSlice2(self: Self, comptime T: type, plane: usize) []const T {
        const ptr = self.vsapi.?.getReadPtr.?(self.frame, @intCast(plane));
        const len = self.getHeight(plane) * self.getStride2(T, plane);
        return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    pub fn getDimensions3(self: Self, plane: usize) struct { width: u32, height: u32, stride: u32 } {
        return .{
            .width = self.getWidth(plane),
            .height = self.getHeight(plane),
            .stride = self.getStride(plane),
        };
    }

    /// read-only!
    pub fn getProperties(self: Self) ZMapRO {
        return .{
            .map = self.vsapi.?.getFramePropertiesRO.?(self.frame),
            .vsapi = self.vsapi,
        };
    }
};

const ZFrameRW = struct {
    frame_ctx: ?*vs.FrameContext,
    core: ?*vs.Core,
    vsapi: ?*const vs.API,
    frame: ?*vs.Frame,
    ro: *const ZFrameRO,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        self.vsapi.?.freeFrame.?(self.frame);
    }

    /// read and write
    pub fn getProperties(self: Self) ZMapRW {
        const map = self.vsapi.?.getFramePropertiesRW.?(self.frame);
        return .{
            .map = map,
            .vsapi = self.vsapi,
            .ro = ZMapRO.init(map, self.vsapi),
        };
    }

    pub fn getWriteSlice(self: Self, plane: usize) []u8 {
        const ptr = self.vsapi.?.getWritePtr.?(self.frame, @intCast(plane));
        const len = self.getHeight(plane) * self.getStride(plane);
        return ptr[0..len];
    }

    pub fn getWriteSlice2(self: Self, comptime T: type, plane: usize) []T {
        const ptr = self.vsapi.?.getWritePtr.?(self.frame, @intCast(plane));
        const len = self.getHeight(plane) * self.getStride2(T, plane);
        return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    pub fn newVideoFrame(self: Self) ZFrameRW {
        return self.ro.newVideoFrame();
    }

    pub fn newVideoFrame2(self: Self, process: [3]bool) ZFrameRW {
        return self.ro.newVideoFrame2(process);
    }

    pub fn newVideoFrame3(self: Self, width: u32, height: u32) ZFrameRW {
        return self.ro.newVideoFrame3(width, height);
    }

    pub fn copyFrame(self: Self) ZFrameRW {
        return self.ro.copyFrame();
    }

    pub fn getHeight(self: Self, plane: usize) u32 {
        return self.ro.getHeight(plane);
    }

    pub fn getWidth(self: Self, plane: usize) u32 {
        return self.ro.getWidth(plane);
    }

    pub fn getStride(self: Self, plane: usize) u32 {
        return self.ro.getStride(plane);
    }

    pub fn getDimensions(self: Self, plane: usize) struct { u32, u32, u32 } {
        return self.ro.getDimensions(plane);
    }

    pub fn getReadSlice(self: Self, plane: usize) []const u8 {
        return self.ro.getReadSlice(plane);
    }

    pub fn getStride2(self: Self, comptime T: type, plane: usize) u32 {
        return self.ro.getStride2(T, plane);
    }

    pub fn getDimensions2(self: Self, comptime T: type, plane: usize) struct { u32, u32, u32 } {
        return self.ro.getDimensions2(T, plane);
    }

    pub fn getReadSlice2(self: Self, comptime T: type, plane: usize) []const T {
        return self.ro.getReadSlice2(T, plane);
    }

    pub fn getDimensions3(self: Self, plane: usize) struct { width: u32, height: u32, stride: u32 } {
        return self.ro.getDimensions3(plane);
    }
};

pub const ZMap = struct {
    pub fn init(map: anytype, vsapi: ?*const vs.API) if (@typeInfo(@TypeOf(map.?)).pointer.is_const) ZMapRO else ZMapRW {
        return if (@typeInfo(@TypeOf(map.?)).pointer.is_const) ZMapRO.init(map, vsapi) else ZMapRW.init(map, vsapi);
    }
};

/// read-only Map
const ZMapRO = struct {
    const Self = @This();
    map: ?*const vs.Map,
    vsapi: ?*const vs.API,

    pub fn init(map: ?*const vs.Map, vsapi: ?*const vs.API) Self {
        return .{
            .map = map,
            .vsapi = vsapi,
        };
    }

    pub fn getNode(self: Self, comptime key: []const u8) ?*vs.Node {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.map, key.ptr, 0, &err);
        return node;
    }

    pub fn getNodeVi(self: Self, comptime key: []const u8) struct { ?*vs.Node, *const vs.VideoInfo } {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.map, key.ptr, 0, &err);
        const vi = self.vsapi.?.getVideoInfo.?(node);
        return .{ node, vi };
    }

    pub fn getNodeVi2(self: Self, comptime key: []const u8) struct { node: ?*vs.Node, vi: *const vs.VideoInfo } {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.map, key.ptr, 0, &err);
        const vi = self.vsapi.?.getVideoInfo.?(node);
        return .{ .node = node, .vi = vi };
    }

    pub fn getInt(self: Self, comptime T: type, comptime key: []const u8) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetInt.?(self.map, key.ptr, 0, &err));
        return if (err == .Success) val else null;
    }

    pub fn getInt2(self: Self, comptime T: type, comptime key: []const u8, index: usize) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetInt.?(self.map, key.ptr, @intCast(index), &err));
        return if (err == .Success) val else null;
    }

    pub fn getFloat(self: Self, comptime T: type, comptime key: []const u8) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetFloat.?(self.map, key.ptr, 0, &err));
        return if (err == .Success) val else null;
    }

    pub fn getFloat2(self: Self, comptime T: type, comptime key: []const u8, index: usize) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetFloat.?(self.map, key.ptr, @intCast(index), &err));
        return if (err == .Success) val else null;
    }

    pub fn getBool(self: Self, comptime key: []const u8) ?bool {
        var err: vs.MapPropertyError = undefined;
        const val = self.vsapi.?.mapGetInt.?(self.map, key.ptr, 0, &err) != 0;
        return if (err == .Success) val else null;
    }

    pub fn getBool2(self: Self, comptime key: []const u8, index: usize) ?bool {
        var err: vs.MapPropertyError = undefined;
        const val = self.vsapi.?.mapGetInt.?(self.map, key.ptr, @intCast(index), &err) != 0;
        return if (err == .Success) val else null;
    }

    pub fn getIntArray(self: Self, comptime key: []const u8) ?[]const i64 {
        const len = self.numElements(key);
        if (len) |n| {
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.vsapi.?.mapGetIntArray.?(self.map, key.ptr, &err);
            return if (err == .Success) arr_ptr.?[0..n] else null;
        } else return null;
    }

    pub fn getFloatArray(self: Self, comptime key: []const u8) ?[]const f64 {
        const len = self.numElements(key);
        if (len) |n| {
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.vsapi.?.mapGetFloatArray.?(self.map, key.ptr, &err);
            return if (err == .Success) arr_ptr.?[0..n] else null;
        } else return null;
    }

    pub fn getData(self: Self, comptime key: []const u8, index: i32) ?[]const u8 {
        var err: vs.MapPropertyError = undefined;
        const len = self.dataSize(key, 0);
        if (len) |n| {
            const ptr = self.vsapi.?.mapGetData.?(self.map, key.ptr, index, &err);
            return if (err == .Success) ptr.?[0..n] else null;
        } else return null;
    }

    fn numElements(self: Self, comptime key: []const u8) ?u32 {
        const ne = self.vsapi.?.mapNumElements.?(self.map, key.ptr);
        return if (ne < 1) null else @as(u32, @bitCast(ne));
    }

    fn dataSize(self: Self, comptime key: []const u8, index: i32) ?u32 {
        var err: vs.MapPropertyError = undefined;
        const len = self.vsapi.?.mapGetDataSize.?(self.map, key.ptr, index, &err);
        return if (len < 1 or err != .Success) null else @as(u32, @bitCast(len));
    }
};

/// read and write Map
const ZMapRW = struct {
    const Self = @This();
    map: ?*vs.Map,
    vsapi: ?*const vs.API,
    ro: ZMapRO,

    pub fn init(map: ?*vs.Map, vsapi: ?*const vs.API) Self {
        return .{
            .map = map,
            .vsapi = vsapi,
            .ro = ZMapRO.init(map, vsapi),
        };
    }

    pub fn setInt(self: Self, key: []const u8, n: i64, mode: vs.MapAppendMode) void {
        _ = self.vsapi.?.mapSetInt.?(self.map, key.ptr, n, mode);
    }

    pub fn setFloat(self: Self, key: []const u8, n: f64, mode: vs.MapAppendMode) void {
        _ = self.vsapi.?.mapSetFloat.?(self.map, key.ptr, n, mode);
    }

    pub fn setIntArray(self: Self, comptime key: []const u8, arr: []const i64) void {
        _ = self.vsapi.?.mapSetIntArray.?(self.map, key.ptr, arr.ptr, @intCast(arr.len));
    }

    pub fn setFloatArray(self: Self, comptime key: []const u8, arr: []const f64) void {
        _ = self.vsapi.?.mapSetFloatArray.?(self.map, key.ptr, arr.ptr, @intCast(arr.len));
    }

    pub fn setData(self: Self, comptime key: []const u8, data: []const u8, dth: vs.DataTypeHint, mode: vs.MapAppendMode) void {
        _ = self.vsapi.?.mapSetData.?(self.map, key.ptr, data.ptr, @intCast(data.len), dth, mode);
    }

    pub fn setError(self: Self, err_msg: []const u8) void {
        self.vsapi.?.mapSetError.?(self.map, err_msg.ptr);
    }

    // ------ read ------ //

    pub fn getNode(self: Self, comptime key: []const u8) ?*vs.Node {
        return self.ro.getNode(key);
    }

    pub fn getNodeVi(self: Self, comptime key: []const u8) struct { ?*vs.Node, *const vs.VideoInfo } {
        return self.ro.getNodeVi(key);
    }

    pub fn getNodeVi2(self: Self, comptime key: []const u8) struct { node: ?*vs.Node, vi: *const vs.VideoInfo } {
        return self.ro.getNodeVi2(key);
    }

    pub fn getInt(self: Self, comptime T: type, comptime key: []const u8) ?T {
        return self.ro.getInt(T, key);
    }

    pub fn getInt2(self: Self, comptime T: type, comptime key: []const u8, index: usize) ?T {
        return self.ro.getInt2(T, key, index);
    }

    pub fn getFloat(self: Self, comptime T: type, comptime key: []const u8) ?T {
        return self.ro.getFloat(T, key);
    }

    pub fn getFloat2(self: Self, comptime T: type, comptime key: []const u8, index: usize) ?T {
        return self.ro.getFloat2(T, key, index);
    }

    pub fn getBool(self: Self, comptime key: []const u8) ?bool {
        return self.ro.getBool(key);
    }

    pub fn getBool2(self: Self, comptime key: []const u8, index: usize) ?bool {
        return self.ro.getBool2(key, index);
    }

    pub fn getIntArray(self: Self, comptime key: []const u8) ?[]const i64 {
        return self.ro.getIntArray(key);
    }

    pub fn getFloatArray(self: Self, comptime key: []const u8) ?[]const f64 {
        return self.ro.getFloatArray(key);
    }

    pub fn getData(self: Self, comptime key: []const u8, index: i32) ?[]const u8 {
        return self.ro.getData(key, index);
    }
};
