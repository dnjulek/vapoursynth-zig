const std = @import("std");
const vs = @import("vapoursynth4.zig");
const math = std.math;

pub const Frame = struct {
    frame_ctx: ?*vs.FrameContext,
    core: ?*vs.Core,
    vsapi: ?*const vs.API,
    frame: ?*const vs.Frame,

    const Self = @This();
    pub fn init(node: ?*vs.Node, n: c_int, frame_ctx: ?*vs.FrameContext, core: ?*vs.Core, vsapi: ?*const vs.API) Self {
        const frame = vsapi.?.getFrameFilter.?(n, node, frame_ctx);
        return .{
            .frame_ctx = frame_ctx,
            .core = core,
            .vsapi = vsapi,
            .frame = frame,
        };
    }

    pub fn deinit(self: *Self) void {
        self.vsapi.?.freeFrame.?(self.frame);
    }

    pub fn newVideoFrame(self: Self) Self {
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
        };
    }

    pub fn newVideoFrame2(self: Self, process: [3]bool) Self {
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
        };
    }

    pub fn geHeight(self: Self, plane: u32) u32 {
        return @bitCast(self.vsapi.?.getFrameHeight.?(self.frame, @bitCast(plane)));
    }

    pub fn geWidth(self: Self, plane: u32) u32 {
        return @bitCast(self.vsapi.?.getFrameWidth.?(self.frame, @bitCast(plane)));
    }

    pub fn getStride(self: Self, plane: u32) u32 {
        return @intCast(self.vsapi.?.getStride.?(self.frame, @bitCast(plane)));
    }

    pub fn getDimensions(self: Self, plane: u32) struct { u32, u32, u32 } {
        return .{ self.geWidth(plane), self.geHeight(plane), self.getStride(plane) };
    }

    pub fn getDimensions2(self: Self, plane: u32) struct { width: u32, height: u32, stride: u32 } {
        return .{
            .width = self.geWidth(plane),
            .height = self.geHeight(plane),
            .stride = self.getStride(plane),
        };
    }

    pub fn getReadPtr(self: Self, plane: u32) []const u8 {
        const ptr = self.vsapi.?.getReadPtr.?(self.frame, @bitCast(plane));
        const len = self.geHeight(plane) * self.getStride(plane);
        return ptr[0..len];
    }

    pub fn getWritePtr(self: Self, plane: u32) []u8 {
        const ptr = self.vsapi.?.getWritePtr.?(@constCast(self.frame), @bitCast(plane));
        const len = self.geHeight(plane) * self.getStride(plane);
        return ptr[0..len];
    }
};

pub const Map = struct {
    in: ?*const vs.Map,
    out: ?*vs.Map,
    vsapi: ?*const vs.API,

    const Self = @This();
    pub fn init(in: ?*const vs.Map, out: ?*vs.Map, vsapi: ?*const vs.API) Map {
        return .{
            .in = in,
            .out = out,
            .vsapi = vsapi,
        };
    }

    pub fn getNode(self: Self, comptime key: []const u8) ?*vs.Node {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.in, key.ptr, 0, &err);
        return node;
    }

    pub fn getNodeVi(self: Self, comptime key: []const u8) struct { ?*vs.Node, *const vs.VideoInfo } {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.in, key.ptr, 0, &err);
        const vi = self.vsapi.?.getVideoInfo.?(node);
        return .{ node, vi };
    }

    pub fn getNodeVi2(self: Self, comptime key: []const u8) struct { node: ?*vs.Node, vi: *const vs.VideoInfo } {
        var err: vs.MapPropertyError = undefined;
        const node = self.vsapi.?.mapGetNode.?(self.in, key.ptr, 0, &err);
        const vi = self.vsapi.?.getVideoInfo.?(node);
        return .{ .node = node, .vi = vi };
    }

    pub fn getInt(self: Self, comptime T: type, comptime key: []const u8) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetInt.?(self.in, key.ptr, 0, &err));
        return if (err == .Success) val else null;
    }

    pub fn getInt2(self: Self, comptime T: type, comptime key: []const u8, index: c_int) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetInt.?(self.in, key.ptr, index, &err));
        return if (err == .Success) val else null;
    }

    pub fn getFloat(self: Self, comptime T: type, comptime key: []const u8) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetFloat.?(self.in, key.ptr, 0, &err));
        return if (err == .Success) val else null;
    }

    pub fn getFloat2(self: Self, comptime T: type, comptime key: []const u8, index: c_int) ?T {
        var err: vs.MapPropertyError = undefined;
        const val: T = math.lossyCast(T, self.vsapi.?.mapGetFloat.?(self.in, key.ptr, index, &err));
        return if (err == .Success) val else null;
    }

    pub fn getBool(self: Self, comptime key: []const u8) ?bool {
        var err: vs.MapPropertyError = undefined;
        const val = self.vsapi.?.mapGetInt.?(self.in, key.ptr, 0, &err) != 0;
        return if (err == .Success) val else null;
    }

    pub fn getBool2(self: Self, comptime key: []const u8, index: c_int) ?bool {
        var err: vs.MapPropertyError = undefined;
        const val = self.vsapi.?.mapGetInt.?(self.in, key.ptr, index, &err) != 0;
        return if (err == .Success) val else null;
    }

    pub fn getIntArray(self: Self, comptime key: []const u8) ?[]const i64 {
        const len = self.numElements(key);
        if (len) |n| {
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.vsapi.?.mapGetIntArray.?(self.in, key.ptr, 0, &err);
            return if (err == .Success) arr_ptr.?[0..n] else null;
        } else return null;
    }

    pub fn getFloatArray(self: Self, comptime key: []const u8) ?[]const f64 {
        const len = self.numElements(key);
        if (len) |n| {
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.vsapi.?.mapGetFloatArray.?(self.in, key.ptr, 0, &err);
            return if (err == .Success) arr_ptr.?[0..n] else null;
        } else return null;
    }

    pub fn getData(self: Self, comptime key: []const u8, data_allocator: std.mem.Allocator, data_buff: *?[]u8) ?[]u8 {
        var err: vs.MapPropertyError = undefined;
        data_buff.* = null;
        const data_ptr = self.self.vsapi.?.mapGetData.?(self.in, key.ptr, 0, &err);
        if (err != .Success) {
            return null;
        }

        const data_len = self.vsapi.?.mapGetDataSize.?(self.in, key.ptr, 0, &err);
        if ((err != .Success) or (data_len < 1)) {
            return null;
        }

        const udata_len: u32 = @bitCast(data_len);
        const data = data_ptr[0..udata_len];
        data_buff.* = data_allocator.alloc(u8, udata_len + 1) catch unreachable;
        const result = std.fmt.bufPrint(data_buff.*.?, "{s}\x00", .{data}) catch unreachable;
        return result[0..(result.len - 1)];
    }

    pub fn setError(self: Self, err_msg: []const u8) void {
        self.vsapi.?.mapSetError.?(self.out, err_msg.ptr);
    }

    pub fn numElements(self: Self, comptime key: []const u8) ?u32 {
        const ne = self.vsapi.?.mapNumElements.?(self.in, key.ptr);
        return if (ne < 1) null else @as(u32, @bitCast(ne));
    }
};
