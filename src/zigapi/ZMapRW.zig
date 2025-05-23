const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");

const ZMapRW = @This();

map: *vs.Map,
zapi: *const ZAPI,

pub fn clear(self: anytype) void {
    self.zapi.clearMap(self.map);
}

pub fn setInt(self: anytype, key: [:0]const u8, n: i64, mode: vs.MapAppendMode) void {
    _ = self.zapi.mapSetInt(self.map, key, n, mode);
}

pub fn setFloat(self: anytype, key: [:0]const u8, n: f64, mode: vs.MapAppendMode) void {
    _ = self.zapi.mapSetFloat(self.map, key, n, mode);
}

pub fn setIntArray(self: anytype, comptime key: [:0]const u8, arr: []const i64) void {
    _ = self.zapi.mapSetIntArray(self.map, key, arr);
}

pub fn setFloatArray(self: anytype, comptime key: [:0]const u8, arr: []const f64) void {
    _ = self.zapi.mapSetFloatArray(self.map, key, arr);
}

pub fn setData(self: anytype, comptime key: [:0]const u8, data: [:0]const u8, dth: vs.DataTypeHint, mode: vs.MapAppendMode) void {
    _ = self.zapi.mapSetData(self.map, key, data, dth, mode);
}

pub fn setError(self: anytype, err_msg: [:0]const u8) void {
    self.zapi.mapSetError(self.map, err_msg);
}

pub fn deleteKey(self: anytype, key: [:0]const u8) void {
    _ = self.zapi.mapDeleteKey(self.map, key);
}

pub fn setEmpty(self: anytype, key: [:0]const u8, pt: vs.PropertyType) i32 {
    return self.zapi.mapSetEmpty(self.map, key, pt);
}

pub fn setNode(self: anytype, key: [:0]const u8, node: ?*vs.Node, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapSetNode(self.map, key, node, mode);
}

pub fn consumeNode(self: anytype, key: [:0]const u8, node: ?*vs.Node, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapConsumeNode(self.map, key, node, mode);
}

pub fn setFrame(self: anytype, key: [:0]const u8, frame: ?*vs.Frame, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapSetFrame(self.map, key, frame, mode);
}

pub fn consumeFrame(self: anytype, key: [:0]const u8, frame: ?*vs.Frame, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapConsumeFrame(self.map, key, frame, mode);
}

pub fn setFunction(self: anytype, key: [:0]const u8, func: ?*vs.Function, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapSetFunction(self.map, key, func, mode);
}

pub fn consumeFunction(self: anytype, key: [:0]const u8, func: ?*vs.Function, mode: vs.MapAppendMode) i32 {
    return self.zapi.mapConsumeFunction(self.map, key, func, mode);
}

pub fn setAlpha(self: anytype, frame: ?*vs.Frame) void {
    _ = self.setFrame("_Alpha", frame, .Replace);
}

pub fn consumeAlpha(self: anytype, frame: ?*vs.Frame) void {
    _ = self.consumeFrame("_Alpha", frame, .Replace);
}

pub fn setChromaLocation(self: anytype, n: vsc.ChromaLocation) void {
    self.setInt("_ChromaLocation", @intFromEnum(n), .Replace);
}

pub fn setColorRange(self: anytype, n: vsc.ColorRange) void {
    self.setInt("_ColorRange", @intFromEnum(n), .Replace);
}

pub fn setFieldBased(self: anytype, n: vsc.FieldBased) void {
    self.setInt("_FieldBased", @intFromEnum(n), .Replace);
}

pub fn setMatrix(self: anytype, n: vsc.MatrixCoefficient) void {
    self.setInt("_Matrix", @intFromEnum(n), .Replace);
}

pub fn setPrimaries(self: anytype, n: vsc.ColorPrimaries) void {
    self.setInt("_Primaries", @intFromEnum(n), .Replace);
}

pub fn setTransfer(self: anytype, n: vsc.TransferCharacteristics) void {
    self.setInt("_Transfer", @intFromEnum(n), .Replace);
}

pub fn setDurationNum(self: anytype, n: i64) void {
    return self.setInt("_DurationNum", n, .Replace);
}

pub fn setDurationDen(self: anytype, n: i64) void {
    return self.setInt("_DurationDen", n, .Replace);
}

pub fn setCombed(self: anytype, n: bool) void {
    return self.setInt("_Combed", @intFromBool(n), .Replace);
}

pub fn setField(self: anytype, n: i64) void {
    return self.setInt("_Field", n, .Replace);
}

pub fn setPictType(self: anytype, data: [:0]const u8) void {
    return self.setData("_PictType", data, .Utf8, .Replace);
}

pub fn setSARNum(self: anytype, n: i64) void {
    return self.setInt("_SARNum", n, .Replace);
}

pub fn setSARDen(self: anytype, n: i64) void {
    return self.setInt("_SARDen", n, .Replace);
}

pub fn setSceneChangeNext(self: anytype, n: bool) void {
    return self.setInt("_SceneChangeNext", @intFromBool(n), .Replace);
}

pub fn setSceneChangePrev(self: anytype, n: bool) void {
    return self.setInt("_SceneChangePrev", @intFromBool(n), .Replace);
}
