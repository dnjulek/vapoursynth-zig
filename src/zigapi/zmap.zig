const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");

pub fn ZMap(comptime MT: type) type {
    return struct {
        const Self = @This();
        map: MT,
        zapi: *const ZAPI,

        pub fn init(map: MT, zapi: *const ZAPI) Self {
            return Self{ .map = map, .zapi = zapi };
        }

        pub fn free(self: *const Self) void {
            self.zapi.freeMap(self.map);
        }

        pub fn getNode(self: *const Self, comptime key: [:0]const u8) ?*vs.Node {
            return self.zapi.mapGetNode(self.map, key, 0, null);
        }

        pub fn getNodeVi(self: *const Self, comptime key: [:0]const u8) ?struct { *vs.Node, *const vs.VideoInfo } {
            var err: vs.MapPropertyError = undefined;
            const node = self.zapi.mapGetNode(self.map, key, 0, &err);
            if (err != .Success) return null;
            return .{ node.?, self.zapi.getVideoInfo(node) };
        }

        pub fn getNodeVi2(self: *const Self, comptime key: [:0]const u8) ?struct { node: *vs.Node, vi: *const vs.VideoInfo } {
            var err: vs.MapPropertyError = undefined;
            const node = self.zapi.mapGetNode(self.map, key, 0, &err);
            if (err != .Success) return null;
            const vi = self.zapi.getVideoInfo(node);
            return .{ .node = node.?, .vi = vi };
        }

        pub fn getValue(self: *const Self, comptime T: type, comptime key: [:0]const u8) ?T {
            return if (@typeInfo(T) == .int) self.getInt(T, key) else self.getFloat(T, key);
        }

        pub fn getValue2(self: *const Self, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
            return if (@typeInfo(T) == .int) self.getInt2(T, key, index) else self.getFloat2(T, key, index);
        }

        pub fn getInt(self: *const Self, comptime T: type, comptime key: [:0]const u8) ?T {
            var err: vs.MapPropertyError = undefined;
            const val: T = math.lossyCast(T, self.zapi.mapGetInt(self.map, key, 0, &err));
            return if (err == .Success) val else null;
        }

        pub fn getInt2(self: *const Self, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
            var err: vs.MapPropertyError = undefined;
            const val: T = math.lossyCast(T, self.zapi.mapGetInt(self.map, key, @intCast(index), &err));
            return if (err == .Success) val else null;
        }

        pub fn getFloat(self: *const Self, comptime T: type, comptime key: [:0]const u8) ?T {
            var err: vs.MapPropertyError = undefined;
            const val: T = math.lossyCast(T, self.zapi.mapGetFloat(self.map, key, 0, &err));
            return if (err == .Success) val else null;
        }

        pub fn getFloat2(self: *const Self, comptime T: type, comptime key: [:0]const u8, index: usize) ?T {
            var err: vs.MapPropertyError = undefined;
            const val: T = math.lossyCast(T, self.zapi.mapGetFloat(self.map, key, @intCast(index), &err));
            return if (err == .Success) val else null;
        }

        pub fn getBool(self: *const Self, comptime key: [:0]const u8) ?bool {
            var err: vs.MapPropertyError = undefined;
            const val = self.zapi.mapGetInt(self.map, key, 0, &err) != 0;
            return if (err == .Success) val else null;
        }

        pub fn getBool2(self: *const Self, comptime key: [:0]const u8, index: usize) ?bool {
            var err: vs.MapPropertyError = undefined;
            const val = self.zapi.mapGetInt(self.map, key, @intCast(index), &err) != 0;
            return if (err == .Success) val else null;
        }

        pub fn getIntArray(self: *const Self, comptime key: [:0]const u8) ?[]const i64 {
            const len: u32 = self.numElements(key) orelse return null;
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.zapi.mapGetIntArray(self.map, key, &err);
            return if (err == .Success) arr_ptr.?[0..len] else null;
        }

        pub fn getFloatArray(self: *const Self, comptime key: [:0]const u8) ?[]const f64 {
            const len: u32 = self.numElements(key) orelse return null;
            var err: vs.MapPropertyError = undefined;
            const arr_ptr = self.zapi.mapGetFloatArray(self.map, key, &err);
            return if (err == .Success) arr_ptr.?[0..len] else null;
        }

        pub fn getData(self: *const Self, comptime key: [:0]const u8, index: i32) ?[]const u8 {
            var err: vs.MapPropertyError = undefined;
            const len: u32 = self.dataSize(key, index) orelse return null;
            const ptr = self.zapi.mapGetData(self.map, key, index, &err);
            return if (err == .Success) ptr.?[0..len] else null;
        }

        pub fn getDataArray(self: *const Self, comptime key: [:0]const u8, allocator: std.mem.Allocator) ?[][]const u8 {
            const len: u32 = self.numElements(key) orelse return null;
            const arr = allocator.alloc([]const u8, len) catch return null;

            for (0..len) |i| {
                arr[i] = self.getData(key, @intCast(i)).?;
            }

            return arr;
        }

        /// getData with null terminator
        pub fn getDataZ(self: *const Self, comptime key: [:0]const u8, index: i32) ?[:0]const u8 {
            var err: vs.MapPropertyError = undefined;
            const len: u32 = self.dataSize(key, index) orelse return null;
            const ptr = self.zapi.mapGetData(self.map, key, index, &err);
            return if (err == .Success) ptr.?[0..len :0] else null;
        }

        pub fn numElements(self: *const Self, comptime key: [:0]const u8) ?u32 {
            const ne = self.zapi.mapNumElements(self.map, key);
            return if (ne < 1) null else @as(u32, @bitCast(ne));
        }

        pub fn dataSize(self: *const Self, comptime key: [:0]const u8, index: i32) ?u32 {
            var err: vs.MapPropertyError = undefined;
            const len = self.zapi.mapGetDataSize(self.map, key, index, &err);
            return if (len < 1 or err != .Success) null else @as(u32, @bitCast(len));
        }

        pub fn numKeys(self: *const Self) i32 {
            return self.zapi.mapNumKeys(self.map);
        }

        pub fn getError(self: *const Self) ?[*:0]const u8 {
            return self.zapi.mapGetError(self.map);
        }

        pub fn getType(self: *const Self, key: [:0]const u8) vs.PropertyType {
            return self.zapi.mapGetType(self.map, key);
        }

        pub fn getDataTypeHint(self: *const Self, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) vs.DataTypeHint {
            return self.zapi.mapGetDataTypeHint(self.map, key, index, err);
        }

        pub fn getFrame(self: *const Self, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) ?*vs.Frame {
            return self.zapi.mapGetFrame(self.map, key, index, err);
        }

        pub fn getFunction(self: *const Self, key: [:0]const u8, index: i32, err: ?*vs.MapPropertyError) ?*vs.Function {
            return self.zapi.mapGetFunction(self.map, key, index, err);
        }

        pub fn invoke(self: *const Self, plugin: ?*vs.Plugin, name: [:0]const u8) ZAPI.ZMap(*vs.Map) {
            const ret = self.zapi.invoke(plugin, name, self.map);
            return self.zapi.initZMap(ret.?);
        }
        // ------ Reserved Frame Properties ------ //

        pub fn getChromaLocation(self: *const Self) ?vsc.ChromaLocation {
            const value: i32 = self.getInt(i32, "_ChromaLocation") orelse return null;
            return if (value < 0 or value > 5) null else @enumFromInt(value);
        }

        pub fn getColorRange(self: *const Self) ?vsc.ColorRange {
            const value: i32 = self.getInt(i32, "_ColorRange") orelse return null;
            return if (value < 0 or value > 1) null else @enumFromInt(value);
        }

        pub fn getFieldBased(self: *const Self) ?vsc.FieldBased {
            const value: i32 = self.getInt(i32, "_FieldBased") orelse return null;
            return if (value < 0 or value > 2) null else @enumFromInt(value);
        }

        pub fn getMatrix(self: *const Self) vsc.MatrixCoefficient {
            const value: i32 = self.getInt(i32, "_Matrix") orelse return .UNSPECIFIED;
            for (std.enums.values(vsc.MatrixCoefficient)) |v| {
                if (@as(i32, @intFromEnum(v)) == value) return v;
            }
            return .UNSPECIFIED;
        }

        pub fn getPrimaries(self: *const Self) vsc.ColorPrimaries {
            const value: i32 = self.getInt(i32, "_Primaries") orelse return .UNSPECIFIED;
            for (std.enums.values(vsc.ColorPrimaries)) |v| {
                if (@as(i32, @intFromEnum(v)) == value) return v;
            }
            return .UNSPECIFIED;
        }

        pub fn getTransfer(self: *const Self) vsc.TransferCharacteristics {
            const value: i32 = self.getInt(i32, "_Transfer") orelse return .UNSPECIFIED;
            for (std.enums.values(vsc.TransferCharacteristics)) |v| {
                if (@as(i32, @intFromEnum(v)) == value) return v;
            }
            return .UNSPECIFIED;
        }

        pub fn getDurationNum(self: *const Self) ?i64 {
            return self.getInt(i64, "_DurationNum");
        }

        pub fn getDurationDen(self: *const Self) ?i64 {
            return self.getInt(i64, "_DurationDen");
        }

        pub fn getCombed(self: *const Self) ?bool {
            return self.getBool("_Combed");
        }

        pub fn getField(self: *const Self) ?i64 {
            return self.getInt(i64, "_Field");
        }

        pub fn getPictType(self: *const Self) ?[:0]const u8 {
            return self.getData("_PictType", 0);
        }

        pub fn getSARNum(self: *const Self) ?i64 {
            return self.getInt(i64, "_SARNum");
        }

        pub fn getSARDen(self: *const Self) ?i64 {
            return self.getInt(i64, "_SARDen");
        }

        pub fn getSceneChangeNext(self: *const Self) ?bool {
            return self.getBool("_SceneChangeNext");
        }

        pub fn getSceneChangePrev(self: *const Self) ?bool {
            return self.getBool("_SceneChangePrev");
        }

        //----------------------------------------------------------------------------------------------------------------------------------------------------

        pub fn clear(self: *const Self) void {
            self.zapi.clearMap(self.map);
        }

        pub fn setInt(self: *const Self, key: [:0]const u8, n: i64, mode: vs.MapAppendMode) void {
            _ = self.zapi.mapSetInt(self.map, key, n, mode);
        }

        pub fn setFloat(self: *const Self, key: [:0]const u8, n: f64, mode: vs.MapAppendMode) void {
            _ = self.zapi.mapSetFloat(self.map, key, n, mode);
        }

        pub fn setIntArray(self: *const Self, comptime key: [:0]const u8, arr: []const i64) void {
            _ = self.zapi.mapSetIntArray(self.map, key, arr);
        }

        pub fn setFloatArray(self: *const Self, comptime key: [:0]const u8, arr: []const f64) void {
            _ = self.zapi.mapSetFloatArray(self.map, key, arr);
        }

        pub fn setData(self: *const Self, comptime key: [:0]const u8, data: [:0]const u8, dth: vs.DataTypeHint, mode: vs.MapAppendMode) void {
            _ = self.zapi.mapSetData(self.map, key, data, dth, mode);
        }

        pub fn setError(self: *const Self, err_msg: [:0]const u8) void {
            self.zapi.mapSetError(self.map, err_msg);
        }

        pub fn deleteKey(self: *const Self, key: [:0]const u8) void {
            _ = self.zapi.mapDeleteKey(self.map, key);
        }

        pub fn setEmpty(self: *const Self, key: [:0]const u8, pt: vs.PropertyType) i32 {
            return self.zapi.mapSetEmpty(self.map, key, pt);
        }

        pub fn setNode(self: *const Self, key: [:0]const u8, node: ?*vs.Node, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapSetNode(self.map, key, node, mode);
        }

        pub fn consumeNode(self: *const Self, key: [:0]const u8, node: ?*vs.Node, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapConsumeNode(self.map, key, node, mode);
        }

        pub fn setFrame(self: *const Self, key: [:0]const u8, frame: ?*vs.Frame, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapSetFrame(self.map, key, frame, mode);
        }

        pub fn consumeFrame(self: *const Self, key: [:0]const u8, frame: ?*vs.Frame, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapConsumeFrame(self.map, key, frame, mode);
        }

        pub fn setFunction(self: *const Self, key: [:0]const u8, func: ?*vs.Function, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapSetFunction(self.map, key, func, mode);
        }

        pub fn consumeFunction(self: *const Self, key: [:0]const u8, func: ?*vs.Function, mode: vs.MapAppendMode) i32 {
            return self.zapi.mapConsumeFunction(self.map, key, func, mode);
        }

        pub fn setAlpha(self: *const Self, frame: ?*vs.Frame) void {
            _ = self.setFrame("_Alpha", frame, .Replace);
        }

        pub fn consumeAlpha(self: *const Self, frame: ?*vs.Frame) void {
            _ = self.consumeFrame("_Alpha", frame, .Replace);
        }

        pub fn setChromaLocation(self: *const Self, n: vsc.ChromaLocation) void {
            self.setInt("_ChromaLocation", @intFromEnum(n), .Replace);
        }

        pub fn setColorRange(self: *const Self, n: vsc.ColorRange) void {
            self.setInt("_ColorRange", @intFromEnum(n), .Replace);
        }

        pub fn setFieldBased(self: *const Self, n: vsc.FieldBased) void {
            self.setInt("_FieldBased", @intFromEnum(n), .Replace);
        }

        pub fn setMatrix(self: *const Self, n: vsc.MatrixCoefficient) void {
            self.setInt("_Matrix", @intFromEnum(n), .Replace);
        }

        pub fn setPrimaries(self: *const Self, n: vsc.ColorPrimaries) void {
            self.setInt("_Primaries", @intFromEnum(n), .Replace);
        }

        pub fn setTransfer(self: *const Self, n: vsc.TransferCharacteristics) void {
            self.setInt("_Transfer", @intFromEnum(n), .Replace);
        }

        pub fn setDurationNum(self: *const Self, n: i64) void {
            return self.setInt("_DurationNum", n, .Replace);
        }

        pub fn setDurationDen(self: *const Self, n: i64) void {
            return self.setInt("_DurationDen", n, .Replace);
        }

        pub fn setCombed(self: *const Self, n: bool) void {
            return self.setInt("_Combed", @intFromBool(n), .Replace);
        }

        pub fn setField(self: *const Self, n: i64) void {
            return self.setInt("_Field", n, .Replace);
        }

        pub fn setPictType(self: *const Self, data: [:0]const u8) void {
            return self.setData("_PictType", data, .Utf8, .Replace);
        }

        pub fn setSARNum(self: *const Self, n: i64) void {
            return self.setInt("_SARNum", n, .Replace);
        }

        pub fn setSARDen(self: *const Self, n: i64) void {
            return self.setInt("_SARDen", n, .Replace);
        }

        pub fn setSceneChangeNext(self: *const Self, n: bool) void {
            return self.setInt("_SceneChangeNext", @intFromBool(n), .Replace);
        }

        pub fn setSceneChangePrev(self: *const Self, n: bool) void {
            return self.setInt("_SceneChangePrev", @intFromBool(n), .Replace);
        }
    };
}
