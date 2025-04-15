const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");
const ZFrameRW = @import("ZFrameRW.zig");
const ZMapRO = @import("ZMapRO.zig");

const ZFrameRO = @This();

frame_ctx: *vs.FrameContext,
core: *vs.Core,
api: *const ZAPI,
frame: *const vs.Frame,

pub fn deinit(self: anytype) void {
    self.api.freeFrame(self.frame);
}

/// Creates a new reading and writing frame with the same properties as the input frame.
/// Use deinit() to free the frame
pub fn newVideoFrame(self: anytype) ZFrameRW {
    const frame = self.api.newVideoFrame(
        self.api.getVideoFrameFormat(self.frame),
        self.api.getFrameWidth(self.frame, 0),
        self.api.getFrameHeight(self.frame, 0),
        self.frame,
        self.core,
    );

    return .{
        .frame_ctx = self.frame_ctx,
        .core = self.core,
        .api = self.api,
        .frame = frame.?,
        // .ro = self,
    };
}

/// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
pub fn newVideoFrame2(self: anytype, process: [3]bool) ZFrameRW {
    var planes = [3]c_int{ 0, 1, 2 };
    var cp_planes = [3]?*const vs.Frame{
        if (process[0]) null else self.frame,
        if (process[1]) null else self.frame,
        if (process[2]) null else self.frame,
    };

    const frame = self.api.newVideoFrame2(
        self.api.getVideoFrameFormat(self.frame),
        self.api.getFrameWidth(self.frame, 0),
        self.api.getFrameHeight(self.frame, 0),
        &cp_planes,
        &planes,
        self.frame,
        self.core,
    );

    return .{
        .frame_ctx = self.frame_ctx,
        .core = self.core,
        .api = self.api,
        .frame = frame.?,
        .ro = self,
    };
}

/// same as newVideoFrame but allows the specified width and height
pub fn newVideoFrame3(self: anytype, width: u32, height: u32) ZFrameRW {
    const frame = self.api.newVideoFrame(
        self.api.getVideoFrameFormat(self.frame),
        @intCast(width),
        @intCast(height),
        self.frame,
        self.core,
    );

    return .{
        .frame_ctx = self.frame_ctx,
        .core = self.core,
        .api = self.api,
        .frame = frame.?,
        .ro = self,
    };
}

/// Duplicates the frame (not just the reference). As the frame buffer is shared in a copy-on-write fashion, the frame content is not really duplicated until a write operation occurs. This is transparent for the user.
/// Returns a pointer to the new frame. Ownership is transferred to the caller.
pub fn copyFrame(self: anytype) ZFrameRW {
    return .{
        .frame_ctx = self.frame_ctx,
        .core = self.core,
        .api = self.api,
        .frame = self.api.copyFrame(self.frame, self.core).?,
        .ro = self,
    };
}

/// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getHeight(self: anytype, plane: usize) u32 {
    return @intCast(self.api.getFrameHeight(self.frame, @intCast(plane)));
}

/// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getWidth(self: anytype, plane: usize) u32 {
    return @intCast(self.api.getFrameWidth(self.frame, @intCast(plane)));
}

/// Returns the distance in bytes between two consecutive lines of a plane of a video frame. The stride is always positive. Returns 0 if the requested plane doesn’t exist or if it isn’t a video frame.
pub fn getStride(self: anytype, plane: usize) u32 {
    return @intCast(self.api.getStride(self.frame, @intCast(plane)));
}

/// Returns the dimensions of a plane. The width, height, and stride are returned in that order as a struct.
pub fn getDimensions(self: anytype, plane: usize) struct { u32, u32, u32 } {
    return .{ self.getWidth(plane), self.getHeight(plane), self.getStride(plane) };
}

/// Returns a read-only slice to a plane or channel of a frame.
/// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
pub fn getReadSlice(self: anytype, plane: usize) []const u8 {
    const ptr = self.api.getReadPtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride(plane);
    return ptr[0..len];
}

/// Same as getStride but returns the stride for type T.
pub fn getStride2(self: anytype, comptime T: type, plane: usize) u32 {
    return @intCast(self.api.getStride(self.frame, @intCast(plane)) >> (@sizeOf(T) >> 1));
}

/// Same as getDimensions but returns the dimensions for type T.
pub fn getDimensions2(self: anytype, comptime T: type, plane: usize) struct { u32, u32, u32 } {
    return .{ self.getWidth(plane), self.getHeight(plane), self.getStride2(T, plane) };
}

/// Same as getReadSlice but returns a slice of type T.
pub fn getReadSlice2(self: anytype, comptime T: type, plane: usize) []const T {
    const ptr = self.api.getReadPtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride2(T, plane);
    return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
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
pub fn getPropertiesRO(self: anytype) ZMapRO {
    return .{
        .map = self.api.getFramePropertiesRO(self.frame).?,
        .api = self.api,
    };
}
