//! Unit tests for the VapourSynth Zig bindings. Run with `zig build test`.
//!
//! These tests need no VapourSynth runtime — they test the bindings as a library.
//! Coverage is organised after the audit in DEBUG.md:
//!
//!   * `compile-coverage:` forces the compiler to analyse and codegen every
//!     wrapper body. Zig analyses function bodies lazily, so a broken wrapper
//!     (e.g. a missing `.?` on an optional fn pointer, or a wrong return type)
//!     only fails to compile once *called*. Summing `&fn` addresses references
//!     each one, surfacing those errors here instead of in downstream plugins.
//!     This is what catches the section-1 bugs from the audit.
//!   * `abi:` locks the C-ABI facts the audit verified field by field — the
//!     116 `VSAPI` function pointers, the enum gotchas (peIndex == 4), the
//!     preset format id formula, and the extern struct layout.
//!   * `ffi-signature:` regression-guards the section-2 type fixes so the
//!     nullable/writable/bit-field corrections cannot silently regress.
//!   * `helper:` exercises the pure `vshelper` math (muldivRational, ceilN,
//!     bitblt, dimension/format comparisons).

const std = @import("std");
const testing = std.testing;

const vapoursynth = @import("vapoursynth");
const vs = vapoursynth.vapoursynth4;
const vsc = vapoursynth.vsconstants;
const vsh = vapoursynth.vshelper;
const vss = vapoursynth.vsscript4;
const ZAPI = vapoursynth.ZAPI;

// ---------------------------------------------------------------------------
// compile-coverage
// ---------------------------------------------------------------------------

/// Sum the address of every non-generic, non-inline `fn` declared on `T`.
/// Taking `&f` forces the compiler to fully analyse and codegen each body,
/// turning latent (lazily-analysed) wrapper bugs into hard compile errors.
///
/// Generic functions (comptime/`anytype` params) and `inline` functions have
/// no single runtime address, so they are skipped here and covered explicitly
/// by `touchGenerics` / the `helper:` tests respectively.
fn refFns(comptime T: type) usize {
    var sum: usize = 0;
    inline for (@typeInfo(T).@"struct".decl_names) |decl_name| {
        const f = @field(T, decl_name);
        const FT = @TypeOf(f);
        if (@typeInfo(FT) == .@"fn") {
            const fi = @typeInfo(FT).@"fn";
            if (!fi.is_generic and fi.attrs.@"callconv" != .@"inline") {
                sum +%= @intFromPtr(&f);
            }
        }
    }
    return sum;
}

test "compile-coverage: every non-generic wrapper body analyses" {
    var sum: usize = 0;
    // Writable instantiations compile *all* method bodies (read + write); the
    // read-only instantiations reuse the same generic source, so analysing the
    // writable ones once is enough to catch a broken body.
    sum +%= refFns(ZAPI);
    sum +%= refFns(ZAPI.Plugin);
    sum +%= refFns(vsh);
    sum +%= refFns(ZAPI.ZMap(*vs.Map));
    sum +%= refFns(ZAPI.ZFrame(*vs.Frame));
    sum +%= @intFromPtr(&touchGenerics);
    try testing.expect(sum != 0);
}

/// Referenced (never called) via `&touchGenerics` above. Instantiates every
/// generic wrapper with concrete types so their bodies are analysed too. The
/// receivers are `undefined` but nothing is executed — only compiled.
fn touchGenerics() void {
    const zapi: *const ZAPI = undefined;

    // ZAPI wrappers that are generic over the map type (`map: anytype`).
    const wmap: *vs.Map = undefined;
    const rmap: *const vs.Map = undefined;
    var ebuf: [16]u8 = undefined;
    _ = zapi.initZMap(wmap);
    _ = zapi.initZMap(rmap);
    _ = zapi.initZMap2(wmap, &ebuf);

    // ZMap: the writable instantiation exercises every generic getter *and*
    // setter; the const instantiation exercises the read-only path.
    const wz = ZAPI.ZMap(*vs.Map).init(wmap, zapi);
    touchZMapReads(wz);
    touchZMapWrites(wz);
    const rz = ZAPI.ZMap(*const vs.Map).init(rmap, zapi);
    touchZMapReads(rz);

    // ZFrame: writable exercises read + write methods, const exercises reads.
    const wframe: *vs.Frame = undefined;
    const wf = ZAPI.ZFrame(*vs.Frame).init(zapi, wframe);
    touchZFrameReads(wf);
    touchZFrameWrites(wf);
    const rframe: *const vs.Frame = undefined;
    const rf = ZAPI.ZFrame(*const vs.Frame).init(zapi, rframe);
    touchZFrameReads(rf);

    // ZAPI.Plugin.config is generic over its `comptime version`.
    const plugin: *vs.Plugin = undefined;
    const papi: *const vs.PLUGINAPI = undefined;
    ZAPI.Plugin.config("id", "ns", "name", .{ .major = 1, .minor = 2, .patch = 3 }, plugin, papi);
}

fn touchZMapReads(z: anytype) void {
    _ = z.getNode("k");
    _ = z.getNodeVi("k");
    _ = z.getNodeVi2("k");
    _ = z.getValue(i32, "k");
    _ = z.getValue2(i64, "k", 0);
    _ = z.getInt(i32, "k");
    _ = z.getInt2(u8, "k", 1);
    _ = z.getFloat(f32, "k");
    _ = z.getFloat2(f64, "k", 1);
    _ = z.getBool("k");
    _ = z.getBool2("k", 1);
    _ = z.getIntArray("k");
    _ = z.getFloatArray("k");
    _ = z.getData("k", 0);
    _ = z.getDataArray("k", testing.allocator);
    _ = z.getDataZ("k", 0);
    _ = z.numElements("k");
    _ = z.dataSize("k", 0);
    _ = z.numKeys();
    _ = z.getError();
    _ = z.getType("k");
    var perr: vs.MapPropertyError = undefined;
    _ = z.getDataTypeHint("k", 0, &perr);
    _ = z.getFrame("k", 0, &perr);
    _ = z.getFunction("k", 0, &perr);
    // reserved frame-property getters (non-generic, but only covered here for
    // the const-map instantiation)
    _ = z.getChromaLocation();
    _ = z.getRange();
    _ = z.getColorRange();
    _ = z.getFieldBased();
    _ = z.getMatrix();
    _ = z.getPrimaries();
    _ = z.getTransfer();
    _ = z.getDurationNum();
    _ = z.getDurationDen();
    _ = z.getCombed();
    _ = z.getField();
    _ = z.getPictType();
    _ = z.getSARNum();
    _ = z.getSARDen();
    _ = z.getSceneChangeNext();
    _ = z.getSceneChangePrev();
}

fn touchZMapWrites(z: anytype) void {
    z.clear();
    z.setInt("k", 1, .Replace);
    z.setFloat("k", 1.0, .Replace);
    z.setIntArray("k", &.{ 1, 2 });
    z.setFloatArray("k", &.{ 1.0, 2.0 });
    z.setData("k", "d", .Utf8, .Replace);
    z.setError("e");
    z.setError2("{s}", .{"e"});
    z.deleteKey("k");
    _ = z.setEmpty("k", .Int);
    const node: ?*vs.Node = null;
    _ = z.setNode("k", node, .Replace);
    _ = z.consumeNode("k", node, .Replace);
    const frame: ?*vs.Frame = null;
    _ = z.setFrame("k", frame, .Replace);
    _ = z.consumeFrame("k", frame, .Replace);
    const func: ?*vs.Function = null;
    _ = z.setFunction("k", func, .Replace);
    _ = z.consumeFunction("k", func, .Replace);
    z.setAlpha(frame);
    z.consumeAlpha(frame);
    z.setChromaLocation(.LEFT);
    z.setRange(.LIMITED);
    z.setColorRange(.LIMITED);
    z.setFieldBased(.PROGRESSIVE);
    z.setMatrix(.BT709);
    z.setPrimaries(.BT709);
    z.setTransfer(.LINEAR);
    z.setDurationNum(1);
    z.setDurationDen(1);
    z.setCombed(false);
    z.setField(1);
    z.setPictType("I");
    z.setSARNum(1);
    z.setSARDen(1);
    z.setSceneChangeNext(true);
    z.setSceneChangePrev(false);
    z.setVideoFormat("k", .GrayS, .Replace);
}

fn touchZFrameReads(z: anytype) void {
    _ = z.getHeight(0);
    _ = z.getWidth(0);
    _ = z.getHeightSigned(0);
    _ = z.getWidthSigned(0);
    _ = z.getStride(0);
    _ = z.getStride2(u8, 0);
    _ = z.getStride2(u16, 0);
    _ = z.getStride2(f32, 0);
    _ = z.getDimensions(0);
    _ = z.getDimensions2(u8, 0);
    _ = z.getDimensions3(0);
    _ = z.getReadSlice(0);
    _ = z.getReadSlices();
    _ = z.getReadSlice2(u8, 0);
    _ = z.getReadSlice2(u16, 0);
    _ = z.getReadSlice2(f32, 0);
    _ = z.getReadSlices2(u8);
    _ = z.getPropertiesRO();
    _ = z.newVideoFrame();
    _ = z.newVideoFrame2(.{ true, false, true });
    _ = z.newVideoFrame3(.{});
    _ = z.copyFrame();
    _ = z.addFrameRef();
}

fn touchZFrameWrites(z: anytype) void {
    _ = z.getWriteSlice(0);
    _ = z.getWriteSlices();
    _ = z.getWriteSlice2(u8, 0);
    _ = z.getWriteSlice2(u16, 0);
    _ = z.getWriteSlices2(u8);
    _ = z.getPropertiesRW();
    z.deinit();
}

// ---------------------------------------------------------------------------
// abi — facts the audit verified against the C headers
// ---------------------------------------------------------------------------

test "abi: VSAPI has exactly 116 function pointers, all nullable" {
    try testing.expectEqual(@as(usize, 116), @typeInfo(vs.API).@"struct".field_types.len);
    inline for (@typeInfo(vs.API).@"struct".field_types) |field_type| {
        try testing.expect(@typeInfo(field_type) == .optional);
    }
}

test "abi: VSSCRIPTAPI and VSPLUGINAPI shapes" {
    inline for (@typeInfo(vss.API).@"struct".field_types) |field_type| {
        try testing.expect(@typeInfo(field_type) == .optional);
    }
    // getAPIVersion, configPlugin, registerFunction
    try testing.expectEqual(@as(usize, 3), @typeInfo(vs.PLUGINAPI).@"struct".field_types.len);
    try testing.expectEqual(@as(c_int, 4), vss.VSSCRIPT_API_MAJOR);
    try testing.expectEqual(@as(c_int, 4), vs.VAPOURSYNTH_API_MAJOR);
}

test "abi: MapPropertyError keeps the swapped Index/Error values" {
    try testing.expectEqual(@as(c_int, 0), @backingInt(vs.MapPropertyError.Success));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vs.MapPropertyError.Unset));
    try testing.expectEqual(@as(c_int, 2), @backingInt(vs.MapPropertyError.Type));
    // the gotcha: index is 4 and error is 3 (not sequential)
    try testing.expectEqual(@as(c_int, 4), @backingInt(vs.MapPropertyError.Index));
    try testing.expectEqual(@as(c_int, 3), @backingInt(vs.MapPropertyError.Error));
}

test "abi: PropertyType values 0..8" {
    try testing.expectEqual(@as(c_int, 0), @backingInt(vs.PropertyType.Unset));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vs.PropertyType.Int));
    try testing.expectEqual(@as(c_int, 2), @backingInt(vs.PropertyType.Float));
    try testing.expectEqual(@as(c_int, 3), @backingInt(vs.PropertyType.Data));
    try testing.expectEqual(@as(c_int, 4), @backingInt(vs.PropertyType.Function));
    try testing.expectEqual(@as(c_int, 5), @backingInt(vs.PropertyType.VideoNode));
    try testing.expectEqual(@as(c_int, 6), @backingInt(vs.PropertyType.AudioNode));
    try testing.expectEqual(@as(c_int, 7), @backingInt(vs.PropertyType.VideoFrame));
    try testing.expectEqual(@as(c_int, 8), @backingInt(vs.PropertyType.AudioFrame));
}

test "abi: AudioChannels keeps the FFmpeg numbering gaps" {
    // gap between TopBackRight (17) and StereoLeft (29)
    try testing.expectEqual(@as(c_int, 17), @backingInt(vs.AudioChannels.TopBackRight));
    try testing.expectEqual(@as(c_int, 29), @backingInt(vs.AudioChannels.StereoLeft));
    try testing.expectEqual(@as(c_int, 30), @backingInt(vs.AudioChannels.StereoRight));
    try testing.expectEqual(@as(c_int, 33), @backingInt(vs.AudioChannels.SurroundDirectLeft));
    try testing.expectEqual(@as(c_int, 35), @backingInt(vs.AudioChannels.LowFrequency2));
}

test "abi: ColorFamily / SampleType / MediaType / ActivationReason" {
    try testing.expectEqual(@as(c_int, 0), @backingInt(vs.ColorFamily.Undefined));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vs.ColorFamily.Gray));
    try testing.expectEqual(@as(c_int, 2), @backingInt(vs.ColorFamily.RGB));
    try testing.expectEqual(@as(c_int, 3), @backingInt(vs.ColorFamily.YUV));
    try testing.expectEqual(@as(c_int, 0), @backingInt(vs.SampleType.Integer));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vs.SampleType.Float));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vs.MediaType.Video));
    try testing.expectEqual(@as(c_int, 2), @backingInt(vs.MediaType.Audio));
    try testing.expectEqual(@as(c_int, -1), @backingInt(vs.ActivationReason.Error));
}

test "abi: preset format ids follow VS_MAKE_VIDEO_ID" {
    // formula: (cf << 28) | (st << 24) | (bps << 16) | (ssw << 8) | ssh
    try testing.expectEqual(vs.makeVideoID(.Gray, .Integer, 8, 0, 0), @backingInt(vs.PresetVideoFormat.Gray8));
    try testing.expectEqual(vs.makeVideoID(.YUV, .Integer, 8, 1, 1), @backingInt(vs.PresetVideoFormat.YUV420P8));
    try testing.expectEqual(vs.makeVideoID(.YUV, .Float, 32, 0, 0), @backingInt(vs.PresetVideoFormat.YUV444PS));
    try testing.expectEqual(vs.makeVideoID(.RGB, .Integer, 8, 0, 0), @backingInt(vs.PresetVideoFormat.RGB24));
    // concrete bit patterns
    try testing.expectEqual(@as(u32, 0x10080000), @backingInt(vs.PresetVideoFormat.Gray8));
    try testing.expectEqual(@as(u32, 0x20080000), @backingInt(vs.PresetVideoFormat.RGB24));
    try testing.expectEqual(@as(u32, 0), @backingInt(vs.PresetVideoFormat.None));
}

test "abi: makeVersion packs major into the high 16 bits" {
    try testing.expectEqual(@as(c_int, (4 << 16) | 1), vs.makeVersion(4, 1));
    try testing.expectEqual(@as(c_int, (4 << 16) | 0), vs.makeVersion(4, 0));
}

test "abi: extern struct layout matches the C ABI (64-bit)" {
    if (@sizeOf(*anyopaque) != 8) return error.SkipZigTest;

    // VideoFormat: 7 tightly-packed c_int
    try testing.expectEqual(@as(usize, 0), @offsetOf(vs.VideoFormat, "colorFamily"));
    try testing.expectEqual(@as(usize, 4), @offsetOf(vs.VideoFormat, "sampleType"));
    try testing.expectEqual(@as(usize, 8), @offsetOf(vs.VideoFormat, "bitsPerSample"));
    try testing.expectEqual(@as(usize, 24), @offsetOf(vs.VideoFormat, "numPlanes"));
    try testing.expectEqual(@as(usize, 28), @sizeOf(vs.VideoFormat));

    // VideoInfo: VideoFormat, then 8-aligned i64 fps, then the c_int dims
    try testing.expectEqual(@as(usize, 0), @offsetOf(vs.VideoInfo, "format"));
    try testing.expectEqual(@as(usize, 32), @offsetOf(vs.VideoInfo, "fpsNum"));
    try testing.expectEqual(@as(usize, 40), @offsetOf(vs.VideoInfo, "fpsDen"));
    try testing.expectEqual(@as(usize, 48), @offsetOf(vs.VideoInfo, "width"));
    try testing.expectEqual(@as(usize, 56), @offsetOf(vs.VideoInfo, "numFrames"));
    try testing.expectEqual(@as(usize, 64), @sizeOf(vs.VideoInfo));

    // CoreInfo: pointer, then ints, with the i64s 8-aligned
    try testing.expectEqual(@as(usize, 0), @offsetOf(vs.CoreInfo, "versionString"));
    try testing.expectEqual(@as(usize, 8), @offsetOf(vs.CoreInfo, "core"));
    try testing.expectEqual(@as(usize, 24), @offsetOf(vs.CoreInfo, "maxFramebufferSize"));
    try testing.expectEqual(@as(usize, 32), @offsetOf(vs.CoreInfo, "usedFramebufferSize"));
}

test "abi: vsconstants reserved-property values (<= API 4.1 range semantics)" {
    // NOTE: VSConstants4.h flips ColorRange under API 4.2 (FULL=1, LIMITED=0).
    // Here the two semantics are separate types: Range (_Range) and ColorRange (_ColorRange).
    try testing.expectEqual(@as(c_int, 1), @backingInt(vsc.Range.FULL));
    try testing.expectEqual(@as(c_int, 0), @backingInt(vsc.Range.LIMITED));
    try testing.expectEqual(@as(c_int, 0), @backingInt(vsc.ColorRange.FULL));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vsc.ColorRange.LIMITED));
    try testing.expectEqual(@as(c_int, 2), @backingInt(vsc.ChromaLocation.TOP_LEFT));
    try testing.expectEqual(@as(c_int, 1), @backingInt(vsc.MatrixCoefficient.BT709));
    try testing.expectEqual(@as(c_int, 9), @backingInt(vsc.MatrixCoefficient.BT2020_NCL));
    try testing.expectEqual(@as(c_int, 16), @backingInt(vsc.TransferCharacteristics.ST2084));
    try testing.expectEqual(@as(c_int, 22), @backingInt(vsc.ColorPrimaries.EBU3213_E));
}

// ---------------------------------------------------------------------------
// ffi-signature — regression guards for the section-2 type fixes
// ---------------------------------------------------------------------------

/// Return the bare `fn(...)` type behind a `?*const fn(...)` struct field.
fn FieldFn(comptime S: type, comptime name: []const u8) type {
    const FieldT = @FieldType(S, name); // ?*const fn(...) ...
    const PtrT = @typeInfo(FieldT).optional.child; // *const fn(...) ...
    return @typeInfo(PtrT).pointer.child; // fn(...) ...
}

fn ReturnOf(comptime FnT: type) type {
    return @typeInfo(FnT).@"fn".return_type.?;
}

test "ffi-signature: getReadPtr / getWritePtr are nullable (C returns NULL on a bad plane)" {
    try testing.expect(ReturnOf(FieldFn(vs.API, "getReadPtr")) == ?[*]const u8);
    try testing.expect(ReturnOf(FieldFn(vs.API, "getWritePtr")) == ?[*]u8);
}

test "ffi-signature: getFrame's errorMsg is a writable buffer" {
    const param_types = @typeInfo(FieldFn(vs.API, "getFrame")).@"fn".param_types;
    try testing.expect(param_types[2].? == ?[*]u8);
}

test "ffi-signature: GetVapourSynthAPI typedef may return NULL" {
    // The audit flagged the typedef (and the matching `extern fn`) as returning a
    // non-optional `*const API` despite documenting a NULL return. We assert the
    // typedef here; the `extern fn` form has the same fixed signature but can't be
    // referenced in a test without linking the VapourSynth shared library.
    const TypedefFn = @typeInfo(@typeInfo(vs.GetVapourSynthAPI).optional.child).pointer.child;
    try testing.expect(ReturnOf(TypedefFn) == ?*const vs.API);
}

test "ffi-signature: FrameDoneCallback's error_msg is optional (NULL on success)" {
    const CbFn = @typeInfo(@typeInfo(vs.FrameDoneCallback).optional.child).pointer.child;
    const param_types = @typeInfo(CbFn).@"fn".param_types;
    try testing.expect(param_types[4].? == ?[*:0]const u8);
}

test "ffi-signature: PresetVideoFormat is non-exhaustive (arbitrary valid ids)" {
    try testing.expect(@typeInfo(vs.PresetVideoFormat).@"enum".mode == .nonexhaustive);
}

test "ffi-signature: CoreCreationFlags is a c_int bit-field" {
    try testing.expect(@typeInfo(vs.CoreCreationFlags) == .@"struct");
    try testing.expectEqual(@bitSizeOf(c_int), @bitSizeOf(vs.CoreCreationFlags));
    // default is no flags
    try testing.expectEqual(@as(c_int, 0), @as(c_int, @bitCast(vs.CoreCreationFlags{})));
    // each flag maps to its C bit value
    try testing.expectEqual(@as(c_int, 1), @as(c_int, @bitCast(vs.CoreCreationFlags{ .enable_graph_inspection = true })));
    try testing.expectEqual(@as(c_int, 2), @as(c_int, @bitCast(vs.CoreCreationFlags{ .disable_auto_loading = true })));
    try testing.expectEqual(@as(c_int, 4), @as(c_int, @bitCast(vs.CoreCreationFlags{ .disable_library_unloading = true })));
    try testing.expectEqual(@as(c_int, 8), @as(c_int, @bitCast(vs.CoreCreationFlags{ .enable_frame_ref_debug = true })));
    // flags combine
    try testing.expectEqual(@as(c_int, 3), @as(c_int, @bitCast(vs.CoreCreationFlags{
        .enable_graph_inspection = true,
        .disable_auto_loading = true,
    })));
}

test "ffi-signature: mapGetFrame returns a const frame (section-1 fix)" {
    // raw API and the ZAPI wrapper agree on ?*const Frame
    try testing.expect(ReturnOf(FieldFn(vs.API, "mapGetFrame")) == ?*const vs.Frame);
    try testing.expect(ReturnOf(@TypeOf(ZAPI.mapGetFrame)) == ?*const vs.Frame);
    try testing.expect(ReturnOf(@TypeOf(ZAPI.ZMap(*vs.Map).getFrame)) == ?*const vs.Frame);
}

// ---------------------------------------------------------------------------
// helper — pure vshelper math
// ---------------------------------------------------------------------------

test "helper: ceilN rounds up to the next power-of-two multiple" {
    try testing.expectEqual(@as(usize, 80), vsh.ceilN(76, 8)); // 76 -> 80 (SIMD pad)
    try testing.expectEqual(@as(usize, 80), vsh.ceilN(80, 8)); // already aligned
    try testing.expectEqual(@as(usize, 0), vsh.ceilN(0, 8));
    try testing.expectEqual(@as(usize, 32), vsh.ceilN(1, 32));
    try testing.expectEqual(@as(usize, 64), vsh.ceilN(33, 32));
}

test "helper: muldivRational scales and reduces in place" {
    var num: i64 = 1;
    var den: i64 = 2;
    vsh.muldivRational(&num, &den, 2, 4); // 1/2 * 2/4 = 2/8 -> 1/4
    try testing.expectEqual(@as(i64, 1), num);
    try testing.expectEqual(@as(i64, 4), den);

    num = 1;
    den = 30000;
    vsh.muldivRational(&num, &den, 1001, 1); // 1001/30000 already reduced
    try testing.expectEqual(@as(i64, 1001), num);
    try testing.expectEqual(@as(i64, 30000), den);

    num = 4;
    den = -8;
    vsh.muldivRational(&num, &den, 1, 1); // 4/-8 -> 1/-2 (gcd taken positive)
    try testing.expectEqual(@as(i64, 1), num);
    try testing.expectEqual(@as(i64, -2), den);

    num = 5;
    den = 0;
    vsh.muldivRational(&num, &den, 7, 3); // den == 0 (variable fps) -> no-op
    try testing.expectEqual(@as(i64, 5), num);
    try testing.expectEqual(@as(i64, 0), den);
}

test "helper: bitblt copies row-by-row honouring strides" {
    // padded source (stride 4) into a tightly-packed destination (stride 3)
    const src = [_]u8{ 1, 2, 3, 99, 4, 5, 6, 99 };
    var dst: [6]u8 = @splat(0);
    vsh.bitblt(&dst, 3, &src, 4, 3, 2);
    try testing.expectEqualSlices(u8, &.{ 1, 2, 3, 4, 5, 6 }, &dst);

    // fast path: stride == row_size on both sides -> single memcpy
    const src2 = [_]u8{ 7, 8, 9, 10 };
    var dst2: [4]u8 = @splat(0);
    vsh.bitblt(&dst2, 2, &src2, 2, 2, 2);
    try testing.expectEqualSlices(u8, &src2, &dst2);

    // height 0 -> no-op
    var dst3: [2]u8 = @splat(42);
    vsh.bitblt(&dst3, 1, &src2, 1, 1, 0);
    try testing.expectEqual(@as(u8, 42), dst3[0]);
}

test "helper: areValidDimensions respects chroma subsampling" {
    const yuv420 = vs.VideoFormat{ .colorFamily = .YUV, .subSamplingW = 1, .subSamplingH = 1 };
    try testing.expect(vsh.areValidDimensions(&yuv420, 4, 4));
    try testing.expect(!vsh.areValidDimensions(&yuv420, 3, 4)); // odd width
    try testing.expect(!vsh.areValidDimensions(&yuv420, 4, 3)); // odd height

    const yuv444 = vs.VideoFormat{ .colorFamily = .YUV }; // ss 0,0
    try testing.expect(vsh.areValidDimensions(&yuv444, 3, 3));
}

test "helper: video format / info comparison" {
    const a = vs.VideoFormat{
        .colorFamily = .YUV,
        .sampleType = .Integer,
        .bitsPerSample = 8,
        .bytesPerSample = 1,
        .subSamplingW = 1,
        .subSamplingH = 1,
        .numPlanes = 3,
    };
    var b = a;
    try testing.expect(vsh.isSameVideoFormat(&a, &b));
    b.bitsPerSample = 10;
    try testing.expect(!vsh.isSameVideoFormat(&a, &b));

    const vi = vs.VideoInfo{ .format = a, .width = 1920, .height = 1080 };
    try testing.expect(vsh.isConstantVideoFormat(&vi));
    const undef = vs.VideoInfo{ .width = 1920, .height = 1080 }; // Undefined color family
    try testing.expect(!vsh.isConstantVideoFormat(&undef));
    const zerodim = vs.VideoInfo{ .format = a, .width = 0, .height = 1080 };
    try testing.expect(!vsh.isConstantVideoFormat(&zerodim));

    var vi2 = vi;
    try testing.expect(vsh.isSameVideoInfo(&vi, &vi2));
    vi2.height = 720;
    try testing.expect(!vsh.isSameVideoInfo(&vi, &vi2));
}

test "helper: audio format / info comparison" {
    const a = vs.AudioFormat{
        .sampleType = .Integer,
        .bitsPerSample = 16,
        .bytesPerSample = 2,
        .numChannels = 2,
        .channelLayout = 0b11,
    };
    var b = a;
    try testing.expect(vsh.isSameAudioFormat(&a, &b));
    b.channelLayout = 0b111;
    try testing.expect(!vsh.isSameAudioFormat(&a, &b));

    const ai = vs.AudioInfo{ .format = a, .sampleRate = 48000 };
    var ai2 = ai;
    try testing.expect(vsh.isSameAudioInfo(&ai, &ai2));
    ai2.sampleRate = 44100;
    try testing.expect(!vsh.isSameAudioInfo(&ai, &ai2));
}

test "helper: PluginID.toString" {
    try testing.expectEqualStrings("com.vapoursynth.std", vsh.PluginID.Std.toString());
    try testing.expectEqualStrings("com.vapoursynth.resize", vsh.PluginID.Resize.toString());
    try testing.expectEqualStrings("com.vapoursynth.text", vsh.PluginID.Text.toString());
}
