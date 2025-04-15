const std = @import("std");
const math = std.math;

const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const ZAPI = @import("ZAPI.zig");

const ZMapRO = @import("ZMapRO.zig");
const ZMapRW = @import("ZMapRW.zig");

pub fn ZMap(comptime MapType: type) type {
    return struct {
        const Self = @This();
        map: MapType,
        api: *const ZAPI,

        pub fn init(map: MapType, api: *const ZAPI) Self {
            return Self{ .map = map, .api = api };
        }

        pub fn free(self: *const Self) void {
            self.api.freeMap(self.map);
        }

        const tinfo = @typeInfo(MapType);
        const is_const = if (tinfo == .optional) @typeInfo(tinfo.optional.child).pointer.is_const else tinfo.pointer.is_const;

        // Conditionally include setter methods only for non-const Maps
        pub usingnamespace if (!is_const) ZMapRW else struct {};
        pub usingnamespace ZMapRO;
    };
}
