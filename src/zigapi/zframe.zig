const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const ZAPI = @import("ZAPI.zig");
const ZFrameRO = @import("ZFrameRO.zig");
const ZFrameRW = @import("ZFrameRW.zig");

const Options = struct {
    format: ?*const vs.VideoFormat = null,
    width: ?i32 = null,
    height: ?i32 = null,
};

pub fn ZFrame(comptime FrameType: type) type {
    return struct {
        api: *const ZAPI,
        core: *vs.Core,
        frame: FrameType,
        frame_ctx: *vs.FrameContext,

        const Self = @This();

        pub fn init(api: *const ZAPI, core: *vs.Core, frame: FrameType, frame_ctx: *vs.FrameContext) Self {
            return Self{
                .api = api,
                .core = core,
                .frame = frame,
                .frame_ctx = frame_ctx,
            };
        }

        /// Creates a new reading and writing frame with the same properties as the input frame.
        /// Use deinit() to free the frame
        pub fn newVideoFrame(self: anytype) ZFrame(*vs.Frame) {
            const frame = self.api.newVideoFrame(
                self.api.getVideoFrameFormat(self.frame),
                self.api.getFrameWidth(self.frame, 0),
                self.api.getFrameHeight(self.frame, 0),
                self.frame,
                self.core,
            );

            return .{
                .api = self.api,
                .core = self.core,
                .frame = frame.?,
                .frame_ctx = self.frame_ctx,
            };
        }

        /// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
        pub fn newVideoFrame2(self: anytype, process: [3]bool) ZFrame(*vs.Frame) {
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
                .api = self.api,
                .core = self.core,
                .frame = frame.?,
                .frame_ctx = self.frame_ctx,
            };
        }

        /// Same as newVideoFrame but with custom format, width and height.
        /// Use this if you want to create a frame with a different format or size than the source frame.
        pub fn newVideoFrame3(self: anytype, options: Options) ZFrame(*vs.Frame) {
            const format = if (options.format != null) options.format.? else self.api.getVideoFrameFormat(self.frame);
            const width = if (options.width != null) options.width.? else self.api.getFrameWidth(self.frame, 0);
            const height = if (options.height != null) options.height.? else self.api.getFrameHeight(self.frame, 0);

            const frame = self.api.newVideoFrame(
                format,
                width,
                height,
                self.frame,
                self.core,
            );

            return .{
                .api = self.api,
                .core = self.core,
                .frame = frame.?,
                .frame_ctx = self.frame_ctx,
            };
        }

        /// Duplicates the frame (not just the reference). As the frame buffer is shared in a copy-on-write fashion, the frame content is not really duplicated until a write operation occurs. This is transparent for the user.
        /// Returns a pointer to the new frame. Ownership is transferred to the caller.
        pub fn copyFrame(self: anytype) ZFrame(*vs.Frame) {
            return .{
                .api = self.api,
                .core = self.core,
                .frame = self.api.copyFrame(self.frame, self.core).?,
                .frame_ctx = self.frame_ctx,
            };
        }

        pub fn deinit(self: anytype) void {
            self.api.freeFrame(self.frame);
        }

        const tinfo = @typeInfo(FrameType);
        const is_const = if (tinfo == .optional) @typeInfo(tinfo.optional.child).pointer.is_const else tinfo.pointer.is_const;

        // Conditionally include setter methods only for non-const Maps
        pub usingnamespace if (!is_const) ZFrameRW else struct {};
        pub usingnamespace ZFrameRO;
    };
}
