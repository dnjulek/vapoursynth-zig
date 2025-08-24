const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const Frame = vs.Frame;
const VideoFormat = vs.VideoFormat;
const ZAPI = @import("ZAPI.zig");

const FrameOptions = struct {
    format: ?*const VideoFormat = null,
    width: ?i32 = null,
    height: ?i32 = null,
};

pub fn ZFrame(comptime FT: type) type {
    return struct {
        const Self = @This();
        zapi: *const ZAPI,
        frame: FT,

        pub fn init(zapi: *const ZAPI, frame: FT) Self {
            return Self{ .zapi = zapi, .frame = frame };
        }

        pub fn deinit(self: *const Self) void {
            self.zapi.freeFrame(self.frame);
        }

        /// Creates a new reading and writing frame with the same properties as the input frame.
        /// Use deinit() to free the frame
        pub fn newVideoFrame(self: *const Self) ZFrame(*Frame) {
            const frame = self.zapi.newVideoFrame(
                self.zapi.getVideoFrameFormat(self.frame),
                self.zapi.getFrameWidth(self.frame, 0),
                self.zapi.getFrameHeight(self.frame, 0),
                self.frame,
            );

            return .{
                .zapi = self.zapi,
                .frame = frame.?,
            };
        }

        /// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
        pub fn newVideoFrame2(self: *const Self, process: [3]bool) ZFrame(*Frame) {
            var planes = [3]c_int{ 0, 1, 2 };
            var cp_planes = [3]?*const Frame{
                if (process[0]) null else self.frame,
                if (process[1]) null else self.frame,
                if (process[2]) null else self.frame,
            };

            const frame = self.zapi.newVideoFrame2(
                self.zapi.getVideoFrameFormat(self.frame),
                self.zapi.getFrameWidth(self.frame, 0),
                self.zapi.getFrameHeight(self.frame, 0),
                &cp_planes,
                &planes,
                self.frame,
            );

            return .{
                .zapi = self.zapi,
                .frame = frame.?,
            };
        }

        /// Same as newVideoFrame but with custom format, width and height.
        /// Use this if you want to create a frame with a different format or size than the source frame.
        pub fn newVideoFrame3(self: *const Self, options: FrameOptions) ZFrame(*Frame) {
            const format = if (options.format != null) options.format.? else self.zapi.getVideoFrameFormat(self.frame);
            const width = if (options.width != null) options.width.? else self.zapi.getFrameWidth(self.frame, 0);
            const height = if (options.height != null) options.height.? else self.zapi.getFrameHeight(self.frame, 0);

            const frame = self.zapi.newVideoFrame(
                format,
                width,
                height,
                self.frame,
            );

            return .{
                .zapi = self.zapi,
                .frame = frame.?,
            };
        }

        /// Duplicates the frame (not just the reference). As the frame buffer is shared in a copy-on-write fashion, the frame content is not really duplicated until a write operation occurs. This is transparent for the user.
        /// Returns a pointer to the new frame. Ownership is transferred to the caller.
        pub fn copyFrame(self: *const Self) ZFrame(*Frame) {
            return .{
                .zapi = self.zapi,
                .frame = self.zapi.copyFrame(self.frame).?,
            };
        }

        /// Returns a read/write Map to a frame’s properties. The Map is valid as long as the frame lives.
        pub fn getPropertiesRW(self: *const Self) ZAPI.ZMap(*vs.Map) {
            const map = self.zapi.getFramePropertiesRW(self.frame).?;
            return ZAPI.ZMap(@TypeOf(map)).init(map, self.zapi);
        }

        /// Returns a read-write slice to a plane or channel of a frame.
        /// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
        pub fn getWriteSlice(self: *const Self, plane: usize) []u8 {
            const ptr = self.zapi.getWritePtr(self.frame, @intCast(plane));
            const len = self.getHeight(plane) * self.getStride(plane);
            return ptr[0..len];
        }

        /// Returns all 3 read-write planes of a frame, do not use with Gray format.
        pub fn getWriteSlices(self: *const Self) [3][]u8 {
            return .{ self.getWriteSlice(0), self.getWriteSlice(1), self.getWriteSlice(2) };
        }

        /// Same as getReadSlice but returns a slice of type T.
        pub fn getWriteSlice2(self: *const Self, comptime T: type, plane: usize) []T {
            const ptr = self.zapi.getWritePtr(self.frame, @intCast(plane));
            const len = self.getHeight(plane) * self.getStride2(T, plane);
            return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
        }

        /// Returns all 3 read-write planes of a frame, do not use with Gray format.
        pub fn getWriteSlices2(self: *const Self, comptime T: type) [3][]T {
            return .{ self.getWriteSlice2(T, 0), self.getWriteSlice2(T, 1), self.getWriteSlice2(T, 2) };
        }

        /// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
        pub fn getHeight(self: *const Self, plane: usize) u32 {
            return @intCast(self.zapi.getFrameHeight(self.frame, @intCast(plane)));
        }

        /// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
        pub fn getWidth(self: *const Self, plane: usize) u32 {
            return @intCast(self.zapi.getFrameWidth(self.frame, @intCast(plane)));
        }

        /// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
        pub fn getHeightSigned(self: *const Self, plane: usize) i32 {
            return self.zapi.getFrameHeight(self.frame, @intCast(plane));
        }

        /// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
        pub fn getWidthSigned(self: *const Self, plane: usize) i32 {
            return self.zapi.getFrameWidth(self.frame, @intCast(plane));
        }

        /// Returns the distance in bytes between two consecutive lines of a plane of a video frame. The stride is always positive. Returns 0 if the requested plane doesn’t exist or if it isn’t a video frame.
        pub fn getStride(self: *const Self, plane: usize) u32 {
            return @intCast(self.zapi.getStride(self.frame, @intCast(plane)));
        }

        /// Returns the dimensions of a plane. The width, height, and stride are returned in that order as a struct.
        pub fn getDimensions(self: *const Self, plane: usize) struct { u32, u32, u32 } {
            return .{ self.getWidth(plane), self.getHeight(plane), self.getStride(plane) };
        }

        /// Returns a read-only slice to a plane or channel of a frame.
        /// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
        pub fn getReadSlice(self: *const Self, plane: usize) []const u8 {
            const ptr = self.zapi.getReadPtr(self.frame, @intCast(plane));
            const len = self.getHeight(plane) * self.getStride(plane);
            return ptr[0..len];
        }

        /// Returns all 3 read-only planes of a frame, do not use with Gray format.
        pub fn getReadSlices(self: *const Self) [3][]const u8 {
            return .{ self.getReadSlice(0), self.getReadSlice(1), self.getReadSlice(2) };
        }

        /// Same as getStride but returns the stride for type T.
        pub fn getStride2(self: *const Self, comptime T: type, plane: usize) u32 {
            return @intCast(self.zapi.getStride(self.frame, @intCast(plane)) >> (@sizeOf(T) >> 1));
        }

        /// Same as getDimensions but returns the dimensions for type T.
        pub fn getDimensions2(self: *const Self, comptime T: type, plane: usize) struct { u32, u32, u32 } {
            return .{ self.getWidth(plane), self.getHeight(plane), self.getStride2(T, plane) };
        }

        /// Same as getReadSlice but returns a slice of type T.
        pub fn getReadSlice2(self: *const Self, comptime T: type, plane: usize) []const T {
            const ptr = self.zapi.getReadPtr(self.frame, @intCast(plane));
            const len = self.getHeight(plane) * self.getStride2(T, plane);
            return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
        }

        /// Returns all 3 read-only planes of a frame, do not use with Gray format.
        pub fn getReadSlices2(self: *const Self, comptime T: type) [3][]const T {
            return .{ self.getReadSlice2(T, 0), self.getReadSlice2(T, 1), self.getReadSlice2(T, 2) };
        }

        /// Same as getDimensions but returns the dimensions as a struct with named fields.
        pub fn getDimensions3(self: *const Self, plane: usize) struct { width: u32, height: u32, stride: u32 } {
            return .{
                .width = self.getWidth(plane),
                .height = self.getHeight(plane),
                .stride = self.getStride(plane),
            };
        }

        /// Returns a read-only Map to a frame’s properties. The Map is valid as long as the frame lives.
        pub fn getPropertiesRO(self: *const Self) ZAPI.ZMap(*const vs.Map) {
            const map = self.zapi.getFramePropertiesRO(self.frame).?;
            return ZAPI.ZMap(@TypeOf(map)).init(map, self.zapi);
        }
    };
}
