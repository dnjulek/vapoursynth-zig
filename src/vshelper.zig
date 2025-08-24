//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VSHelper4.h

const std = @import("std");
const vs = @import("vapoursynth4.zig");
const math = std.math;

pub const STD_PLUGIN_ID = "com.vapoursynth.std";
pub const RESIZE_PLUGIN_ID = "com.vapoursynth.resize";
pub const TEXT_PLUGIN_ID = "com.vapoursynth.text";

pub const PluginID = enum {
    Std,
    Resize,
    Text,

    pub fn toString(self: PluginID) [:0]const u8 {
        return switch (self) {
            .Std => STD_PLUGIN_ID,
            .Resize => RESIZE_PLUGIN_ID,
            .Text => TEXT_PLUGIN_ID,
        };
    }
};

/// convenience function for checking if the format never changes between frames
pub fn isConstantVideoFormat(vi: *const vs.VideoInfo) bool {
    return (vi.height > 0) and (vi.width > 0) and (vi.format.colorFamily != .Undefined);
}

/// convenience function to check if two clips have the same format (unknown/changeable will be considered the same too)
pub fn isSameVideoFormat(v1: *const vs.VideoFormat, v2: *const vs.VideoFormat) bool {
    return (v1.colorFamily == v2.colorFamily) and (v1.sampleType == v2.sampleType) and (v1.bitsPerSample == v2.bitsPerSample) and
        (v1.subSamplingW == v2.subSamplingW) and (v1.subSamplingH == v2.subSamplingH);
}

/// convenience function to check if a clip has the same format as a format id
pub fn isSameVideoPresetFormat(presetFormat: u32, v: *const vs.VideoFormat, core: ?*vs.Core, vsapi: *const vs.API) bool {
    return vsapi.queryVideoFormatID(v.colorFamily, v.sampleType, v.bitsPerSample, v.subSamplingW, v.subSamplingH, core) == presetFormat;
}

/// convenience function to check for if two clips have the same format (but not framerate)
/// while also including width and height (unknown/changeable will be considered the same too)
pub fn isSameVideoInfo(v1: *const vs.VideoInfo, v2: *const vs.VideoInfo) bool {
    return (v1.height == v2.height) and (v1.width == v2.width) and isSameVideoFormat(&v1.format, &v2.format);
}

/// convenience function to check for if two clips have the same format while also including samplerate
/// (unknown/changeable will be considered the same too)
pub fn isSameAudioFormat(a1: *const vs.AudioFormat, a2: *const vs.AudioFormat) bool {
    return (a1.bitsPerSample == a2.bitsPerSample) and (a1.sampleType == a2.sampleType) and (a1.channelLayout == a2.channelLayout);
}

/// convenience function to check for if two clips have the same format while also including samplerate
/// (unknown/changeable will be considered the same too)
pub fn isSameAudioInfo(a1: *const vs.AudioInfo, a2: *const vs.AudioInfo) bool {
    return (a1.sampleRate == a2.sampleRate) and isSameAudioFormat(&a1.format, &a2.format);
}

pub inline fn bitblt(dstp: anytype, dst_stride: usize, srcp: anytype, src_stride: usize, row_size: usize, height: usize) void {
    if (height > 0) {
        if ((src_stride == dst_stride) and (src_stride == row_size)) {
            const length: usize = row_size * height;
            @memcpy(dstp[0..length], srcp[0..length]);
        } else {
            var srcp8: [*]const u8 = @ptrCast(@alignCast(srcp));
            var dstp8: [*]u8 = @ptrCast(@alignCast(dstp));
            var i: usize = 0;
            while (i < height) : (i += 1) {
                @memcpy(dstp8[0..row_size], srcp8[0..row_size]);
                srcp8 += src_stride;
                dstp8 += dst_stride;
            }
        }
    }
}

/// check if the frame dimensions are valid for a given format
/// returns non-zero for valid width and height
pub fn areValidDimensions(fi: *const vs.VideoFormat, width: c_int, height: c_int) c_int {
    return !((width % (1 << fi.subSamplingW)) || (height % (1 << fi.subSamplingH)));
}

/// multiplies and divides a rational number, such as a frame duration, in place and reduces the result
pub inline fn muldivRational(num: *i64, den: *i64, mul: i64, div: i64) void {
    std.debug.assert(div != 0);

    num.* *= mul;
    den.* *= div;
    var a: i64 = num.*;
    var b: i64 = den.*;

    while (b != 0) {
        const t: i64 = a;
        a = b;
        b = @mod(t, b);

        if (a < 0) {
            a = -a;
        }

        num.* = @divTrunc(num.*, a);
        den.* = @divTrunc(den.*, a);
    }
}

pub inline fn ceilN(x: usize, n: usize) usize {
    return (x + (n - 1)) & ~(n - 1);
}

/// Helper to use Zig Optionals and saturate to return type
/// https://ziglang.org/documentation/master/#Optionals
pub fn mapGetN(comptime T: type, in: ?*const vs.Map, key: [*:0]const u8, index: u32, vsapi: ?*const vs.API) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = switch (@typeInfo(T)) {
        .int => math.lossyCast(T, vsapi.?.mapGetInt.?(in, key, @intCast(index), &err)),
        .float => math.lossyCast(T, vsapi.?.mapGetFloat.?(in, key, @intCast(index), &err)),
        .bool => vsapi.?.mapGetInt.?(in, key, @intCast(index), &err) != 0,
        else => @compileError("mapGetN only works with Int, Float and Bool types"),
    };

    return if (err == .Success) val else null;
}

/// Format the string with a null-terminator to work properly with C API, you need to free the buf manually.
pub fn printf(allocator: std.mem.Allocator, buf: *?[]u8, comptime fmt: []const u8, args: anytype) []const u8 {
    const err_msg = "Out of memory occurred while writing string.";
    buf.* = allocator.alloc(u8, std.fmt.count(fmt, args) + 1) catch null; // +1 for "\x00" in bufPrintZ
    return if (buf.*) |b| std.fmt.bufPrintZ(b, fmt, args) catch err_msg else err_msg;
}
