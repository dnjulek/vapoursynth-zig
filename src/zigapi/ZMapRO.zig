const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");

const ZMapRO = @This();

map: *const vs.Map,
api: *const ZAPI,

pub fn getNode(self: anytype, comptime key: [:0]const u8) ?*vs.Node {
    var err: vs.MapPropertyError = undefined;
    const node = self.api.mapGetNode(self.map, key, 0, &err);
    return node;
}

pub fn getNodeVi(self: anytype, comptime key: [:0]const u8) struct { ?*vs.Node, *const vs.VideoInfo } {
    var err: vs.MapPropertyError = undefined;
    const node = self.api.mapGetNode(self.map, key, 0, &err);
    const vi = self.api.getVideoInfo(node);
    return .{ node, vi };
}

pub fn getNodeVi2(self: anytype, comptime key: [:0]const u8) struct { node: ?*vs.Node, vi: *const vs.VideoInfo } {
    var err: vs.MapPropertyError = undefined;
    const node = self.api.mapGetNode(self.map, key, 0, &err);
    const vi = self.api.getVideoInfo(node);
    return .{ .node = node, .vi = vi };
}

pub fn getInt(self: anytype, comptime T: type, comptime key: [:0]const u8) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.api.mapGetInt(self.map, key, 0, &err));
    return if (err == .Success) val else null;
}

pub fn getInt2(self: anytype, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.api.mapGetInt(self.map, key, @intCast(index), &err));
    return if (err == .Success) val else null;
}

pub fn getFloat(self: anytype, comptime T: type, comptime key: [:0]const u8) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.api.mapGetFloat(self.map, key, 0, &err));
    return if (err == .Success) val else null;
}

pub fn getFloat2(self: anytype, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.api.mapGetFloat(self.map, key, @intCast(index), &err));
    return if (err == .Success) val else null;
}

pub fn getBool(self: anytype, comptime key: [:0]const u8) ?bool {
    var err: vs.MapPropertyError = undefined;
    const val = self.api.mapGetInt(self.map, key, 0, &err) != 0;
    return if (err == .Success) val else null;
}

pub fn getBool2(self: anytype, comptime key: [:0]const u8, index: usize) ?bool {
    var err: vs.MapPropertyError = undefined;
    const val = self.api.mapGetInt(self.map, key, @intCast(index), &err) != 0;
    return if (err == .Success) val else null;
}

pub fn getIntArray(self: anytype, comptime key: [:0]const u8) ?[]const i64 {
    const len = self.numElements(key);
    if (len) |n| {
        var err: vs.MapPropertyError = undefined;
        const arr_ptr = self.api.mapGetIntArray(self.map, key, &err);
        return if (err == .Success) arr_ptr.?[0..n] else null;
    } else return null;
}

pub fn getFloatArray(self: anytype, comptime key: [:0]const u8) ?[]const f64 {
    const len = self.numElements(key);
    if (len) |n| {
        var err: vs.MapPropertyError = undefined;
        const arr_ptr = self.api.mapGetFloatArray(self.map, key, &err);
        return if (err == .Success) arr_ptr.?[0..n] else null;
    } else return null;
}

pub fn getData(self: anytype, comptime key: [:0]const u8, index: i32) ?[:0]const u8 {
    var err: vs.MapPropertyError = undefined;
    const len = self.dataSize(key, index);
    if (len) |n| {
        const ptr = self.api.mapGetData(self.map, key, index, &err);
        return if (err == .Success) ptr.?[0..n] else null;
    } else return null;
}

pub fn numElements(self: anytype, comptime key: [:0]const u8) ?u32 {
    const ne = self.api.mapNumElements(self.map, key);
    return if (ne < 1) null else @as(u32, @bitCast(ne));
}

pub fn dataSize(self: anytype, comptime key: [:0]const u8, index: i32) ?u32 {
    var err: vs.MapPropertyError = undefined;
    const len = self.api.mapGetDataSize(self.map, key, index, &err);
    return if (len < 1 or err != .Success) null else @as(u32, @bitCast(len));
}

// ------ Reserved Frame Properties ------ //

pub fn getChromaLocation(self: anytype) ?vsc.ChromaLocation {
    const value: i32 = self.getInt(i32, "_ChromaLocation") orelse return null;
    return if (value < 0 or value > 5) null else @enumFromInt(value);
}

pub fn getColorRange(self: anytype) ?vsc.ColorRange {
    const value: i32 = self.getInt(i32, "_ColorRange") orelse return null;
    return if (value < 0 or value > 1) null else @enumFromInt(value);
}

pub fn getFieldBased(self: anytype) ?vsc.FieldBased {
    const value: i32 = self.getInt(i32, "_FieldBased") orelse return null;
    return if (value < 0 or value > 2) null else @enumFromInt(value);
}

pub fn getMatrix(self: anytype) ?vsc.MatrixCoefficient {
    const value: i32 = self.getInt(i32, "_Matrix") orelse return null;
    for (std.enums.values(vsc.MatrixCoefficient)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return null;
}

pub fn getPrimaries(self: anytype) ?vsc.ColorPrimaries {
    const value: i32 = self.getInt(i32, "_Primaries") orelse return null;
    for (std.enums.values(vsc.ColorPrimaries)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return null;
}

pub fn getTransfer(self: anytype) ?vsc.TransferCharacteristics {
    const value: i32 = self.getInt(i32, "_Transfer") orelse return null;
    for (std.enums.values(vsc.TransferCharacteristics)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return null;
}

pub fn getDurationNum(self: anytype) ?i64 {
    return self.getInt(i64, "_DurationNum");
}

pub fn getDurationDen(self: anytype) ?i64 {
    return self.getInt(i64, "_DurationDen");
}

pub fn getCombed(self: anytype) ?bool {
    return self.getBool("_Combed");
}

pub fn getField(self: anytype) ?i64 {
    return self.getInt(i64, "_Field");
}

pub fn getPictType(self: anytype) ?[:0]const u8 {
    return self.getData("_PictType", 0);
}

pub fn getSARNum(self: anytype) ?i64 {
    return self.getInt(i64, "_SARNum");
}

pub fn getSARDen(self: anytype) ?i64 {
    return self.getInt(i64, "_SARDen");
}

pub fn getSceneChangeNext(self: anytype) ?bool {
    return self.getBool("_SceneChangeNext");
}

pub fn getSceneChangePrev(self: anytype) ?bool {
    return self.getBool("_SceneChangePrev");
}
