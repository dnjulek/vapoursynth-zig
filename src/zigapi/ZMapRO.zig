const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");

const ZMapRO = @This();

map: *const vs.Map,
zapi: *const ZAPI,

pub fn getNode(self: anytype, comptime key: [:0]const u8) ?*vs.Node {
    var err: vs.MapPropertyError = undefined;
    const node = self.zapi.mapGetNode(self.map, key, 0, &err);
    return node;
}

pub fn getNodeVi(self: anytype, comptime key: [:0]const u8) ?struct { *vs.Node, *const vs.VideoInfo } {
    var err: vs.MapPropertyError = undefined;
    const node = self.zapi.mapGetNode(self.map, key, 0, &err);
    if (err != .Success) return null;
    const vi = self.zapi.getVideoInfo(node);
    return .{ node.?, vi };
}

pub fn getNodeVi2(self: anytype, comptime key: [:0]const u8) ?struct { node: *vs.Node, vi: *const vs.VideoInfo } {
    var err: vs.MapPropertyError = undefined;
    const node = self.zapi.mapGetNode(self.map, key, 0, &err);
    if (err != .Success) return null;
    const vi = self.zapi.getVideoInfo(node);
    return .{ .node = node.?, .vi = vi };
}

pub fn getValue(self: anytype, comptime T: type, comptime key: [:0]const u8) ?T {
    return if (@typeInfo(T) == .int) self.getInt(T, key) else self.getFloat(T, key);
}

pub fn getValue2(self: anytype, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
    return if (@typeInfo(T) == .int) self.getInt2(T, key, index) else self.getFloat2(T, key, index);
}

pub fn getInt(self: anytype, comptime T: type, comptime key: [:0]const u8) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.zapi.mapGetInt(self.map, key, 0, &err));
    return if (err == .Success) val else null;
}

pub fn getInt2(self: anytype, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.zapi.mapGetInt(self.map, key, @intCast(index), &err));
    return if (err == .Success) val else null;
}

pub fn getFloat(self: anytype, comptime T: type, comptime key: [:0]const u8) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.zapi.mapGetFloat(self.map, key, 0, &err));
    return if (err == .Success) val else null;
}

pub fn getFloat2(self: anytype, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
    var err: vs.MapPropertyError = undefined;
    const val: T = math.lossyCast(T, self.zapi.mapGetFloat(self.map, key, @intCast(index), &err));
    return if (err == .Success) val else null;
}

pub fn getBool(self: anytype, comptime key: [:0]const u8) ?bool {
    var err: vs.MapPropertyError = undefined;
    const val = self.zapi.mapGetInt(self.map, key, 0, &err) != 0;
    return if (err == .Success) val else null;
}

pub fn getBool2(self: anytype, comptime key: [:0]const u8, index: usize) ?bool {
    var err: vs.MapPropertyError = undefined;
    const val = self.zapi.mapGetInt(self.map, key, @intCast(index), &err) != 0;
    return if (err == .Success) val else null;
}

pub fn getIntArray(self: anytype, comptime key: [:0]const u8) ?[]const i64 {
    const len: u32 = self.numElements(key) orelse return null;
    var err: vs.MapPropertyError = undefined;
    const arr_ptr = self.zapi.mapGetIntArray(self.map, key, &err);
    return if (err == .Success) arr_ptr.?[0..len] else null;
}

pub fn getFloatArray(self: anytype, comptime key: [:0]const u8) ?[]const f64 {
    const len: u32 = self.numElements(key) orelse return null;
    var err: vs.MapPropertyError = undefined;
    const arr_ptr = self.zapi.mapGetFloatArray(self.map, key, &err);
    return if (err == .Success) arr_ptr.?[0..len] else null;
}

pub fn getData(self: anytype, comptime key: [:0]const u8, index: i32) ?[]const u8 {
    var err: vs.MapPropertyError = undefined;
    const len: u32 = self.dataSize(key, index) orelse return null;
    const ptr = self.zapi.mapGetData(self.map, key, index, &err);
    return if (err == .Success) ptr.?[0..len] else null;
}

pub fn getDataArray(self: anytype, comptime key: [:0]const u8, allocator: std.mem.Allocator) ?[][]const u8 {
    const len: u32 = self.numElements(key) orelse return null;
    const arr = allocator.alloc([]const u8, len) catch return null;

    for (0..len) |i| {
        arr[i] = self.getData(key, @intCast(i)).?;
    }

    return arr;
}

/// getData with null terminator
pub fn getDataZ(self: anytype, comptime key: [:0]const u8, index: i32) ?[:0]const u8 {
    var err: vs.MapPropertyError = undefined;
    const len: u32 = self.dataSize(key, index) orelse return null;
    const ptr = self.zapi.mapGetData(self.map, key, index, &err);
    return if (err == .Success) ptr.?[0..len :0] else null;
}

pub fn numElements(self: anytype, comptime key: [:0]const u8) ?u32 {
    const ne = self.zapi.mapNumElements(self.map, key);
    return if (ne < 1) null else @as(u32, @bitCast(ne));
}

pub fn dataSize(self: anytype, comptime key: [:0]const u8, index: i32) ?u32 {
    var err: vs.MapPropertyError = undefined;
    const len = self.zapi.mapGetDataSize(self.map, key, index, &err);
    return if (len < 1 or err != .Success) null else @as(u32, @bitCast(len));
}

pub fn numKeys(self: anytype) i32 {
    return self.zapi.mapNumKeys(self.map);
}

pub fn getError(self: anytype) ?[*:0]const u8 {
    return self.zapi.mapGetError(self.map);
}

pub fn getType(self: anytype, key: [:0]const u8) vs.PropertyType {
    return self.zapi.mapGetType(self.map, key);
}

pub fn getDataTypeHint(self: anytype, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) vs.DataTypeHint {
    return self.zapi.mapGetDataTypeHint(self.map, key, index, err);
}

pub fn getFrame(self: anytype, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) ?*vs.Frame {
    return self.zapi.mapGetFrame(self.map, key, index, err);
}

pub fn getFunction(self: anytype, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) ?*vs.Function {
    return self.zapi.mapGetFunction(self.map, key, index, err);
}

pub fn invoke(self: anytype, plugin: ?*vs.Plugin, name: [:0]const u8) ZAPI.ZMap(*vs.Map) {
    const ret = self.zapi.invoke(plugin, name, self.map);
    return self.zapi.initZMap(ret.?);
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

pub fn getMatrix(self: anytype) vsc.MatrixCoefficient {
    const value: i32 = self.getInt(i32, "_Matrix") orelse return .UNSPECIFIED;
    for (std.enums.values(vsc.MatrixCoefficient)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return .UNSPECIFIED;
}

pub fn getPrimaries(self: anytype) vsc.ColorPrimaries {
    const value: i32 = self.getInt(i32, "_Primaries") orelse return .UNSPECIFIED;
    for (std.enums.values(vsc.ColorPrimaries)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return .UNSPECIFIED;
}

pub fn getTransfer(self: anytype) vsc.TransferCharacteristics {
    const value: i32 = self.getInt(i32, "_Transfer") orelse return .UNSPECIFIED;
    for (std.enums.values(vsc.TransferCharacteristics)) |v| {
        if (@as(i32, @intFromEnum(v)) == value) return v;
    }
    return .UNSPECIFIED;
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
