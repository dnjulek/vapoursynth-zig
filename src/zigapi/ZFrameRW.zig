const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const ZAPI = @import("ZAPI.zig");
const zmap = @import("zmap.zig");

const ZFrameRW = @This();

frame_ctx: *vs.FrameContext,
core: *vs.Core,
api: *const ZAPI,
frame: *vs.Frame,

/// Returns a read/write Map to a frame’s properties. The Map is valid as long as the frame lives.
pub fn getPropertiesRW(self: anytype) zmap.ZMap(*vs.Map) {
    const map = self.api.getFramePropertiesRW(self.frame).?;
    return zmap.ZMap(@TypeOf(map)).init(map, self.api);
}

/// Returns a read-write slice to a plane or channel of a frame.
/// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
pub fn getWriteSlice(self: anytype, plane: usize) []u8 {
    const ptr = self.api.getWritePtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride(plane);
    return ptr[0..len];
}

/// Same as getReadSlice but returns a slice of type T.
pub fn getWriteSlice2(self: anytype, comptime T: type, plane: usize) []T {
    const ptr = self.api.getWritePtr(self.frame, @intCast(plane));
    const len = self.getHeight(plane) * self.getStride2(T, plane);
    return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
}
