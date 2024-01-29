//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VSHelper4.h

const std = @import("std");
const vs = @import("vapoursynth4.zig");
const cf = vs.ColorFamily;

pub const STD_PLUGIN_ID = "com.vapoursynth.std";
pub const RESIZE_PLUGIN_ID = "com.vapoursynth.resize";
pub const TEXT_PLUGIN_ID = "com.vapoursynth.text";

/// convenience function for checking if the format never changes between frames
pub fn isConstantVideoFormat(vi: *const vs.VideoInfo) callconv(.C) bool {
    return (vi.height > 0) and (vi.width > 0) and (vi.format.colorFamily != cf.Undefined);
}

/// convenience function to check if two clips have the same format (unknown/changeable will be considered the same too)
pub fn isSameVideoFormat(v1: *const vs.VideoFormat, v2: *const vs.VideoFormat) callconv(.C) bool {
    return (v1.colorFamily == v2.colorFamily) and (v1.sampleType == v2.sampleType) and (v1.bitsPerSample == v2.bitsPerSample) and
        (v1.subSamplingW == v2.subSamplingW) and (v1.subSamplingH == v2.subSamplingH);
}

/// convenience function to check if a clip has the same format as a format id
pub fn isSameVideoPresetFormat(presetFormat: u32, v: *const vs.VideoFormat, core: ?*vs.Core, vsapi: *const vs.API) callconv(.C) bool {
    return vsapi.queryVideoFormatID(v.colorFamily, v.sampleType, v.bitsPerSample, v.subSamplingW, v.subSamplingH, core) == presetFormat;
}

/// convenience function to check for if two clips have the same format (but not framerate)
/// while also including width and height (unknown/changeable will be considered the same too)
pub fn isSameVideoInfo(v1: *const vs.VideoInfo, v2: *const vs.VideoInfo) callconv(.C) bool {
    return (v1.height == v2.height) and (v1.width == v2.width) and isSameVideoFormat(&v1.format, &v2.format);
}

/// convenience function to check for if two clips have the same format while also including samplerate
/// (unknown/changeable will be considered the same too)
pub fn isSameAudioFormat(a1: *const vs.AudioFormat, a2: *const vs.AudioFormat) callconv(.C) bool {
    return (a1.bitsPerSample == a2.bitsPerSample) and (a1.sampleType == a2.sampleType) and (a1.channelLayout == a2.channelLayout);
}

/// convenience function to check for if two clips have the same format while also including samplerate
/// (unknown/changeable will be considered the same too)
pub fn isSameAudioInfo(a1: *const vs.AudioInfo, a2: *const vs.AudioInfo) callconv(.C) bool {
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
pub fn areValidDimensions(fi: *const vs.VideoFormat, width: c_int, height: c_int) callconv(.C) c_int {
    return !((width % (1 << fi.subSamplingW)) || (height % (1 << fi.subSamplingH)));
}

/// multiplies and divides a rational number, such as a frame duration, in place and reduces the result
inline fn muldivRational(num: *i64, den: *i64, mul: i64, div: i64) void {
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

pub inline fn ceil_n(x: usize, n: usize) usize {
    return (x + (n - 1)) & ~(n - 1);
}
