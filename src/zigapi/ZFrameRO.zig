const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const ZAPI = @import("ZAPI.zig");

const ZFrameRO = @This();

frame_ctx: *vs.FrameContext,
zapi: *const ZAPI,
frame: *const vs.Frame,

/// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getHeight(self: anytype, plane: usize) u32 {
    return @intCast(self.zapi.getFrameHeight(self.frame, @intCast(plane)));
}

/// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getWidth(self: anytype, plane: usize) u32 {
    return @intCast(self.zapi.getFrameWidth(self.frame, @intCast(plane)));
}

/// Returns the distance in bytes between two consecutive lines of a plane of a video frame. The stride is always positive. Returns 0 if the requested plane doesn’t exist or if it isn’t a video frame.
pub fn getStride(self: anytype, plane: usize) u32 {
    return @intCast(self.zapi.getStride(self.frame, @intCast(plane)));
}

/// Returns the dimensions of a plane. The width, height, and stride are returned in that order as a struct.
pub fn getDimensions(self: anytype, plane: usize) struct { u32, u32, u32 } {
    return .{ self.getWidth(plane), self.getHeight(plane), self.getStride(plane) };
}

/// Returns a read-only slice to a plane or channel of a frame.
/// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
pub fn getReadSlice(self: anytype, plane: usize) []const u8 {
    const ptr = self.zapi.getReadPtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride(plane);
    return ptr[0..len];
}

/// Returns all 3 read-only planes of a frame, do not use with Gray format.
pub fn getReadSlices(self: anytype) [3][]const u8 {
    return .{ self.getReadSlice(0), self.getReadSlice(1), self.getReadSlice(2) };
}

/// Same as getStride but returns the stride for type T.
pub fn getStride2(self: anytype, comptime T: type, plane: usize) u32 {
    return @intCast(self.zapi.getStride(self.frame, @intCast(plane)) >> (@sizeOf(T) >> 1));
}

/// Same as getDimensions but returns the dimensions for type T.
pub fn getDimensions2(self: anytype, comptime T: type, plane: usize) struct { u32, u32, u32 } {
    return .{ self.getWidth(plane), self.getHeight(plane), self.getStride2(T, plane) };
}

/// Same as getReadSlice but returns a slice of type T.
pub fn getReadSlice2(self: anytype, comptime T: type, plane: usize) []const T {
    const ptr = self.zapi.getReadPtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride2(T, plane);
    return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
}

/// Returns all 3 read-only planes of a frame, do not use with Gray format.
pub fn getReadSlices2(self: anytype, comptime T: type) [3][]const T {
    return .{ self.getReadSlice2(T, 0), self.getReadSlice2(T, 1), self.getReadSlice2(T, 2) };
}

/// Same as getDimensions but returns the dimensions as a struct with named fields.
pub fn getDimensions3(self: anytype, plane: usize) struct { width: u32, height: u32, stride: u32 } {
    return .{
        .width = self.getWidth(plane),
        .height = self.getHeight(plane),
        .stride = self.getStride(plane),
    };
}

/// Returns a read-only Map to a frame’s properties. The Map is valid as long as the frame lives.
pub fn getPropertiesRO(self: anytype) ZAPI.ZMap(*const vs.Map) {
    const map = self.zapi.getFramePropertiesRO(self.frame).?;
    return ZAPI.ZMap(@TypeOf(map)).init(map, self.zapi);
}
