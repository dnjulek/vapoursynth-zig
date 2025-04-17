//! Zig API for VapourSynth

const std = @import("std");
const module = @import("../module.zig");
const vs = module.vapoursynth4;
const vsc = module.vsconstants;
const vsh = module.vshelper;

const ZFrameRO = @import("ZFrameRO.zig");
const ZFrameRW = @import("ZFrameRW.zig");
const ZMapRO = @import("ZMapRO.zig");
const ZMapRW = @import("ZMapRW.zig");

const AudioFormat = vs.AudioFormat;
const AudioInfo = vs.AudioInfo;
const CacheMode = vs.CacheMode;
const ColorFamily = vs.ColorFamily;
const Core = vs.Core;
const CoreCreationFlags = vs.CoreCreationFlags;
const CoreInfo = vs.CoreInfo;
const DataTypeHint = vs.DataTypeHint;
const FilterDependency = vs.FilterDependency;
const FilterFree = vs.FilterFree;
const FilterGetFrame = vs.FilterGetFrame;
const FilterMode = vs.FilterMode;
const Frame = vs.Frame;
const FrameContext = vs.FrameContext;
const FrameDoneCallback = vs.FrameDoneCallback;
const FreeFunctionData = vs.FreeFunctionData;
const Function = vs.Function;
const LogHandle = vs.LogHandle;
const LogHandler = vs.LogHandler;
const LogHandlerFree = vs.LogHandlerFree;
const Map = vs.Map;
const MapAppendMode = vs.MapAppendMode;
const MapPropertyError = vs.MapPropertyError;
const MediaType = vs.MediaType;
const MessageType = vs.MessageType;
const Node = vs.Node;
const Plugin = vs.Plugin;
const PluginFunction = vs.PluginFunction;
const PresetVideoFormat = vs.PresetVideoFormat;
const PropertyType = vs.PropertyType;
const PublicFunction = vs.PublicFunction;
const SampleType = vs.SampleType;
const VideoFormat = vs.VideoFormat;
const VideoInfo = vs.VideoInfo;

const ZAPI = @This();

vsapi: *const vs.API,

pub fn init(vsapi: ?*const vs.API) ZAPI {
    return .{ .vsapi = vsapi.? };
}

pub fn initZFrame(
    self: *const ZAPI,
    node: ?*vs.Node,
    n: c_int,
    frame_ctx: ?*vs.FrameContext,
    core: ?*vs.Core,
) ZFrame(*const vs.Frame) {
    const frame = self.vsapi.getFrameFilter.?(n, node, frame_ctx).?;
    return ZFrame(@TypeOf(frame)).init(self, core.?, frame, frame_ctx.?);
}

pub fn initZMap(self: *const ZAPI, map: anytype) ZMap(@TypeOf(map)) {
    return ZMap(@TypeOf(map)).init(map, self);
}

pub fn createZMap(self: *const ZAPI) ZMap(*vs.Map) {
    const map = self.vsapi.createMap.?().?;
    return ZMap(@TypeOf(map)).init(map, self);
}

/// output nodes are appended to the clip key in the out map
pub fn createVideoFilter(self: *const ZAPI, out: ?*Map, name: [:0]const u8, vi: *const VideoInfo, gf: FilterGetFrame, free: FilterFree, mode: FilterMode, dep: []const FilterDependency, data: ?*anyopaque, core: ?*Core) void {
    self.vsapi.createVideoFilter.?(out, name.ptr, vi, gf, free, mode, dep.ptr, @intCast(dep.len), data, core);
}
/// same as createVideoFilter but returns a pointer to the VSNode directly or NULL on failure
pub fn createVideoFilter2(self: *const ZAPI, name: [:0]const u8, vi: *const VideoInfo, gf: FilterGetFrame, free: FilterFree, mode: FilterMode, dep: []const FilterDependency, instance_data: ?*anyopaque, core: ?*Core) ?*Node {
    return self.vsapi.createVideoFilter2.?(name.ptr, vi, gf, free, mode, dep.ptr, @intCast(dep.len), instance_data, core);
}
/// output nodes are appended to the clip key in the out map
pub fn createAudioFilter(self: *const ZAPI, out: ?*Map, name: [:0]const u8, ai: *const AudioInfo, gf: FilterGetFrame, free: FilterFree, mode: FilterMode, dep: []const FilterDependency, instance_data: ?*anyopaque, core: ?*Core) void {
    self.vsapi.createAudioFilter.?(out, name.ptr, ai, gf, free, mode, dep.ptr, @intCast(dep.len), instance_data, core);
}
/// same as createAudioFilter but returns a pointer to the VSNode directly or NULL on failure
pub fn createAudioFilter2(self: *const ZAPI, name: [:0]const u8, ai: *const AudioInfo, gf: FilterGetFrame, free: FilterFree, mode: FilterMode, dep: []const FilterDependency, instance_data: ?*anyopaque, core: ?*Core) ?*Node {
    return self.vsapi.createAudioFilter2.?(name.ptr, ai, gf, free, mode, dep.ptr, @intCast(dep.len), instance_data, core);
}
/// Use right after create*Filter*, sets the correct cache mode for using the cacheFrame API and returns the recommended upper number of additional frames to cache per request
pub fn setLinearFilter(self: *const ZAPI, node: ?*Node) i32 {
    return self.vsapi.setLinearFilter.?(node);
}
/// VSCacheMode, changing the cache mode also resets all options to their default
pub fn setCacheMode(self: *const ZAPI, node: ?*Node, mode: CacheMode) void {
    self.vsapi.setCacheMode.?(node, mode);
}
/// passing -1 means no change
pub fn setCacheOptions(self: *const ZAPI, node: ?*Node, fixed_size: i32, max_size: i32, max_history_size: i32) void {
    self.vsapi.setCacheOptions.?(node, fixed_size, max_size, max_history_size);
}
/// Decreases the reference count of a node and destroys it once it reaches 0.
pub fn freeNode(self: *const ZAPI, node: ?*Node) void {
    self.vsapi.freeNode.?(node);
}
/// Increment the reference count of a node. Returns the same node for convenience.
pub fn addNodeRef(self: *const ZAPI, node: ?*Node) ?*Node {
    return self.vsapi.addNodeRef.?(node);
}
/// Returns VSMediaType. Used to determine if a node is of audio or video type.
pub fn getNodeType(self: *const ZAPI, node: ?*Node) MediaType {
    return self.vsapi.getNodeType.?(node);
}
/// Returns a pointer to the video info associated with a node. The pointer is valid as long as the node lives. It is undefined behavior to pass a non-video node.
pub fn getVideoInfo(self: *const ZAPI, node: ?*Node) *const VideoInfo {
    return self.vsapi.getVideoInfo.?(node);
}
/// Returns a pointer to the audio info associated with a node. The pointer is valid as long as the node lives. It is undefined behavior to pass a non-audio node.
pub fn getAudioInfo(self: *const ZAPI, node: ?*Node) *const AudioInfo {
    return self.vsapi.getAudioInfo.?(node);
}
/// Creates a new video frame, optionally copying the properties attached to another frame. It is a fatal error to pass invalid arguments to this function.
/// The new frame contains uninitialised memory.
pub fn newVideoFrame(self: *const ZAPI, vf: *const VideoFormat, width: i32, height: i32, src: ?*const Frame, core: ?*Core) ?*Frame {
    return self.vsapi.newVideoFrame.?(vf, width, height, src, core);
}
/// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
pub fn newVideoFrame2(self: *const ZAPI, vf: *const VideoFormat, width: i32, height: i32, frames: []?*const Frame, plane: []const i32, src: ?*const Frame, core: ?*Core) ?*Frame {
    return self.vsapi.newVideoFrame2.?(vf, width, height, frames.ptr, plane.ptr, src, core);
}
/// Creates a new audio frame, optionally copying the properties attached to another frame. It is a fatal error to pass invalid arguments to this function.
/// The new frame contains uninitialised memory.
pub fn newAudioFrame(self: *const ZAPI, af: *const AudioFormat, num_samples: i32, src: ?*const Frame, core: ?*Core) ?*Frame {
    return self.vsapi.newAudioFrame.?(af, num_samples, src, core);
}
/// same as newAudioFrame but allows the specified channels to be effectively copied from the source frames
pub fn newAudioFrame2(self: *const ZAPI, af: *const AudioFormat, num_samples: i32, frames: []?*const Frame, channels: []const i32, src: ?*const Frame, core: ?*Core) ?*Frame {
    return self.vsapi.newAudioFrame2.?(af, num_samples, frames.ptr, channels.ptr, src, core);
}
/// Decrements the reference count of a frame and deletes it when it reaches 0.
pub fn freeFrame(self: *const ZAPI, frame: ?*const Frame) void {
    self.vsapi.freeFrame.?(frame);
}
/// Increments the reference count of a frame. Returns f as a convenience.
pub fn addFrameRef(self: *const ZAPI, frame: ?*const Frame) ?*const Frame {
    return self.vsapi.addFrameRef.?(frame);
}
/// Duplicates the frame (not just the reference). As the frame buffer is shared in a copy-on-write fashion, the frame content is not really duplicated until a write operation occurs. This is transparent for the user.
/// Returns a pointer to the new frame. Ownership is transferred to the caller.
pub fn copyFrame(self: *const ZAPI, frame: ?*const Frame, core: ?*Core) ?*Frame {
    return self.vsapi.copyFrame.?(frame, core);
}
/// Returns a read-only pointer to a frame’s properties. The pointer is valid as long as the frame lives.
pub fn getFramePropertiesRO(self: *const ZAPI, frame: ?*const Frame) ?*const Map {
    return self.vsapi.getFramePropertiesRO.?(frame);
}
/// Returns a read/write pointer to a frame’s properties. The pointer is valid as long as the frame lives.
pub fn getFramePropertiesRW(self: *const ZAPI, frame: ?*Frame) ?*Map {
    return self.vsapi.getFramePropertiesRW.?(frame);
}
/// Returns the distance in bytes between two consecutive lines of a plane of a video frame. The stride is always positive. Returns 0 if the requested plane doesn’t exist or if it isn’t a video frame.
pub fn getStride(self: *const ZAPI, frame: ?*const Frame, plane: i32) isize {
    return self.vsapi.getStride.?(frame, plane);
}
/// Returns a read-only pointer to a plane or channel of a frame. Returns NULL if an invalid plane or channel number is passed.
/// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
pub fn getReadPtr(self: *const ZAPI, frame: ?*const Frame, plane: i32) [*]const u8 {
    return self.vsapi.getReadPtr.?(frame, plane);
}
/// Returns a read-write pointer to a plane or channel of a frame. Returns NULL if an invalid plane or channel number is passed.
/// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
pub fn getWritePtr(self: *const ZAPI, frame: ?*Frame, plane: i32) [*]u8 {
    return self.vsapi.getWritePtr.?(frame, plane);
}
/// Retrieves the format of a video frame.
pub fn getVideoFrameFormat(self: *const ZAPI, frame: ?*const Frame) *const VideoFormat {
    return self.vsapi.getVideoFrameFormat.?(frame);
}
/// Retrieves the format of an audio frame.
pub fn getAudioFrameFormat(self: *const ZAPI, frame: ?*const Frame) *const AudioFormat {
    return self.vsapi.getAudioFrameFormat.?(frame);
}
/// Returns a value from VSMediaType to distinguish audio and video frames.
pub fn getFrameType(self: *const ZAPI, frame: ?*const Frame) MediaType {
    return self.vsapi.getFrameType.?(frame);
}
/// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getFrameWidth(self: *const ZAPI, frame: ?*const Frame, plane: i32) i32 {
    return self.vsapi.getFrameWidth.?(frame, plane);
}
/// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
pub fn getFrameHeight(self: *const ZAPI, frame: ?*const Frame, plane: i32) i32 {
    return self.vsapi.getFrameHeight.?(frame, plane);
}
/// Returns the number of audio samples in a frame. Always returns 1 for video frames.
pub fn getFrameLength(self: *const ZAPI, frame: ?*const Frame) i32 {
    return self.vsapi.getFrameLength.?(frame);
}
/// Tries to output a fairly human-readable name of a video format.
/// buf: Destination buffer. At most 32 bytes including terminating NULL will be written.
pub fn getVideoFormatName(self: *const ZAPI, vf: *const VideoFormat, buf: []u8) i32 {
    return self.vsapi.getVideoFormatName.?(vf, buf.ptr);
}
/// Tries to output a fairly human-readable name of an audio format.
/// buf: Destination buffer. At most 32 bytes including terminating NULL will be written.
pub fn getAudioFormatName(self: *const ZAPI, af: *const AudioFormat, buf: []u8) i32 {
    return self.vsapi.getAudioFormatName.?(af, buf.ptr);
}
/// Fills out a VSVideoInfo struct based on the provided arguments. Validates the arguments before filling out format.
pub fn queryVideoFormat(self: *const ZAPI, vf: *VideoFormat, cf: ColorFamily, st: SampleType, bps: i32, ssw: i32, ssh: i32, core: ?*Core) i32 {
    return self.vsapi.queryVideoFormat.?(vf, cf, st, bps, ssw, ssh, core);
}
/// Fills out a VSAudioFormat struct based on the provided arguments. Validates the arguments before filling out format.
pub fn queryAudioFormat(self: *const ZAPI, af: *AudioFormat, st: SampleType, bps: i32, cl: u64, core: ?*Core) i32 {
    return self.vsapi.queryAudioFormat.?(af, st, bps, cl, core);
}
/// Get the id associated with a video format. Similar to queryVideoFormat() except that it returns a format id instead of filling out a VSVideoInfo struct.
pub fn queryVideoFormatID(self: *const ZAPI, cf: ColorFamily, st: SampleType, bps: i32, ssw: i32, ssh: i32, core: ?*Core) PresetVideoFormat {
    return self.vsapi.queryVideoFormatID.?(cf, st, bps, ssw, ssh, core);
}
/// Fills out the VSVideoFormat struct passed to format based
pub fn getVideoFormatByID(self: *const ZAPI, vf: *VideoFormat, id: PresetVideoFormat, core: ?*Core) i32 {
    return self.vsapi.getVideoFormatByID.?(vf, id, core);
}
pub fn getVideoFormatID(self: *const ZAPI, vi: *const VideoInfo, core: ?*Core) PresetVideoFormat {
    return self.queryVideoFormatID(vi.format.colorFamily, vi.format.sampleType, vi.format.bitsPerSample, vi.format.subSamplingW, vi.format.subSamplingH, core);
}
/// Fetches a frame synchronously. The frame is available when the function returns.
/// This function is meant for external applications using the core as a library, or if frame requests are necessary during a filter’s initialization.
pub fn getFrame(self: *const ZAPI, n: i32, node: ?*Node, error_msg: ?[*]const u8, buf_size: i32) ?*const Frame {
    return self.vsapi.getFrame.?(n, node, error_msg, buf_size);
}
/// Requests the generation of a frame. When the frame is ready, a user-provided function is called. Note that the completion callback will only be called from a single thread at a time.
/// This function is meant for applications using VapourSynth as a library.
pub fn getFrameAsync(self: *const ZAPI, n: i32, node: ?*Node, callback: FrameDoneCallback, user_data: ?*anyopaque) void {
    self.vsapi.getFrameAsync.?(n, node, callback, user_data);
}
/// Retrieves a frame that was previously requested with requestFrameFilter(). Only use inside a filter's getframe function
pub fn getFrameFilter(self: *const ZAPI, n: i32, node: ?*Node, context: ?*FrameContext) ?*const Frame {
    return self.vsapi.getFrameFilter.?(n, node, context);
}
/// Requests a frame from a node and returns immediately. Only use inside a filter's getframe function
pub fn requestFrameFilter(self: *const ZAPI, n: i32, node: ?*Node, context: ?*FrameContext) void {
    self.vsapi.requestFrameFilter.?(n, node, context);
}
/// By default all requested frames are referenced until a filter’s frame request is done. In extreme cases where a filter needs to reduce 20+ frames
/// into a single output frame it may be beneficial to request these in batches and incrementally process the data instead.
pub fn releaseFrameEarly(self: *const ZAPI, node: ?*Node, n: i32, context: ?*FrameContext) void {
    self.vsapi.releaseFrameEarly.?(node, n, context);
}
/// Pushes a not requested frame into the cache. This is useful for (source) filters that greatly benefit from completely linear access and producing all output in linear order.
/// This function may only be used in filters that were created with setLinearFilter.
pub fn cacheFrame(self: *const ZAPI, frame: ?*const Frame, n: i32, context: ?*FrameContext) void {
    self.vsapi.cacheFrame.?(frame, n, context);
}
/// Adds an error message to a frame context, replacing the existing message, if any.
/// This is the way to report errors in a filter’s “getframe” function. Such errors are not necessarily fatal, i.e. the caller can try to request the same frame again.
pub fn setFilterError(self: *const ZAPI, error_message: [:0]const u8, context: ?*FrameContext) void {
    self.vsapi.setFilterError.?(error_message.ptr, context);
}
// External functions
pub fn createFunction(self: *const ZAPI, func: PublicFunction, user_data: ?*anyopaque, free: FreeFunctionData, core: ?*Core) ?*Function {
    return self.vsapi.createFunction.?(func, user_data, free, core);
}
/// Decrements the reference count of a function and deletes it when it reaches 0.
pub fn freeFunction(self: *const ZAPI, func: ?*Function) void {
    self.vsapi.freeFunction.?(func);
}
/// Increments the reference count of a function. Returns f as a convenience.
pub fn addFunctionRef(self: *const ZAPI, func: ?*Function) ?*Function {
    return self.vsapi.addFunctionRef.?(func);
}
/// Calls a function. If the call fails out will have an error set.
pub fn callFunction(self: *const ZAPI, func: ?*Function, in: ?*const Map, out: ?*Map) void {
    self.vsapi.callFunction.?(func, in, out);
}
/// Creates a new property map. It must be deallocated later with freeMap().
pub fn createMap(self: *const ZAPI) ?*Map {
    return self.vsapi.createMap.?();
}
/// Frees a map and all the objects it contains.
pub fn freeMap(self: *const ZAPI, map: ?*Map) void {
    self.vsapi.freeMap.?(map);
}
/// Deletes all the keys and their associated values from the map, leaving it empty.
pub fn clearMap(self: *const ZAPI, map: ?*Map) void {
    self.vsapi.clearMap.?(map);
}
/// copies all values in src to dst, if a key already exists in dst it's replaced
pub fn copyMap(self: *const ZAPI, src: ?*const Map, dst: ?*Map) void {
    self.vsapi.copyMap.?(src, dst);
}
/// Adds an error message to a map. The map is cleared first. The error message is copied. In this state the map may only be freed, cleared or queried for the error message.
/// For errors encountered in a filter’s “getframe” function, use setFilterError.
pub fn mapSetError(self: *const ZAPI, out: ?*Map, error_message: [:0]const u8) void {
    self.vsapi.mapSetError.?(out, error_message.ptr);
}
/// Returns a pointer to the error message contained in the map, or NULL if there is no error set. The pointer is valid until the next modifying operation on the map.
pub fn mapGetError(self: *const ZAPI, in: ?*const Map) ?[*]const u8 {
    return self.vsapi.mapGetError.?(in);
}
/// Returns the number of keys contained in a property map.
pub fn mapNumKeys(self: *const ZAPI, in: ?*const Map) i32 {
    return self.vsapi.mapNumKeys.?(in);
}
/// Returns the nth key from a property map. Passing an invalid index will cause a fatal error. The pointer is valid as long as the key exists in the map.
pub fn mapGetKey(self: *const ZAPI, in: ?*const Map, index: i32) [*]const u8 {
    return self.vsapi.mapGetKey.?(in, index);
}
/// Removes the property with the given key. All values associated with the key are lost. Returns 0 if the key isn’t in the map. Otherwise it returns 1.
pub fn mapDeleteKey(self: *const ZAPI, map: ?*Map, key: [:0]const u8) i32 {
    return self.vsapi.mapDeleteKey.?(map, key.ptr);
}
/// Returns the number of elements associated with a key in a property map. Returns -1 if there is no such key in the map.
pub fn mapNumElements(self: *const ZAPI, map: ?*const Map, key: [:0]const u8) i32 {
    return self.vsapi.mapNumElements.?(map, key.ptr);
}
/// Returns a value from VSPropertyType representing type of elements in the given key. If there is no such key in the map, the returned value is ptUnset. Note that also empty arrays created with mapSetEmpty are typed.
pub fn mapGetType(self: *const ZAPI, map: ?*const Map, key: [:0]const u8) PropertyType {
    return self.vsapi.mapGetType.?(map, key.ptr);
}
/// Creates an empty array of type in key. Returns non-zero value on failure due to key already existing or having an invalid name.
pub fn mapSetEmpty(self: *const ZAPI, map: ?*Map, key: [:0]const u8, pt: PropertyType) i32 {
    return self.vsapi.mapSetEmpty.?(map, key.ptr, pt);
}
/// Retrieves an integer from a specified key in a map. Returns the number on success, or 0 in case of error. If the map has an error set (i.e. if mapGetError() returns non-NULL), VapourSynth will die with a fatal error.
pub fn mapGetInt(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) i64 {
    return self.vsapi.mapGetInt.?(map, key.ptr, index, err);
}
/// Works just like mapGetInt() except that the value returned is also converted to an integer using saturation.
pub fn mapGetIntSaturated(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) i32 {
    return self.vsapi.mapGetIntSaturated.?(map, key.ptr, index, err);
}
/// Retrieves an array of integers from a map. Use this function if there are a lot of numbers associated with a key, because it is faster than calling mapGetInt() in a loop.
/// Returns a pointer to the first element of the array on success, or NULL in case of error. Use mapNumElements() to know the total number of elements associated with a key.
pub fn mapGetIntArray(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, err: ?*MapPropertyError) ?[*]const i64 {
    return self.vsapi.mapGetIntArray.?(map, key.ptr, err);
}
/// Sets an integer to the specified key in a map. Multiple values can be associated with one key, but they must all be the same type.
pub fn mapSetInt(self: *const ZAPI, map: ?*Map, key: [:0]const u8, n: i64, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetInt.?(map, key.ptr, n, mode);
}
/// Adds an array of integers to a map. Use this function if there are a lot of numbers to add, because it is faster than calling mapSetInt() in a loop.
/// If map already contains a property with this key, that property will be overwritten and all old values will be lost.
pub fn mapSetIntArray(self: *const ZAPI, map: ?*Map, key: [:0]const u8, arr: []const i64) i32 {
    return self.vsapi.mapSetIntArray.?(map, key.ptr, arr.ptr, @intCast(arr.len));
}
///Retrieves a floating point number from a map. Returns the number on success, or 0 in case of error.
pub fn mapGetFloat(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) f64 {
    return self.vsapi.mapGetFloat.?(map, key.ptr, index, err);
}
/// Works just like mapGetFloat() except that the value returned is also converted to a f32.
pub fn mapGetFloatSaturated(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) f32 {
    return self.vsapi.mapGetFloatSaturated.?(map, key.ptr, index, err);
}
/// Retrieves an array of floating point numbers from a map. Use this function if there are a lot of numbers associated with a key, because it is faster than calling mapGetFloat() in a loop.
/// Returns a pointer to the first element of the array on success, or NULL in case of error. Use mapNumElements() to know the total number of elements associated with a key.
pub fn mapGetFloatArray(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, err: ?*MapPropertyError) ?[*]const f64 {
    return self.vsapi.mapGetFloatArray.?(map, key.ptr, err);
}
/// Sets a float to the specified key in a map.
pub fn mapSetFloat(self: *const ZAPI, map: ?*Map, key: [:0]const u8, n: f64, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetFloat.?(map, key.ptr, n, mode);
}
/// Adds an array of floating point numbers to a map. Use this function if there are a lot of numbers to add, because it is faster than calling mapSetFloat() in a loop.
pub fn mapSetFloatArray(self: *const ZAPI, map: ?*Map, key: [:0]const u8, arr: []const f64) i32 {
    return self.vsapi.mapSetFloatArray.?(map, key.ptr, arr.ptr, @intCast(arr.len));
}
/// Retrieves arbitrary binary data from a map. Checking mapGetDataTypeHint() may provide a hint about whether or not the data is human readable.
pub fn mapGetData(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) ?[*]const u8 {
    return self.vsapi.mapGetData.?(map, key.ptr, index, err);
}
/// Returns the size in bytes of a property of type ptData (see VSPropertyType), or 0 in case of error. The terminating NULL byte added by mapSetData() is not counted.
pub fn mapGetDataSize(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) i32 {
    return self.vsapi.mapGetDataSize.?(map, key.ptr, index, err);
}
/// Returns the size in bytes of a property of type ptData (see VSPropertyType), or 0 in case of error. The terminating NULL byte added by mapSetData() is not counted.
pub fn mapGetDataTypeHint(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) DataTypeHint {
    return self.vsapi.mapGetDataTypeHint.?(map, key.ptr, index, err);
}
/// Sets binary data to the specified key in a map. Multiple values can be associated with one key, but they must all be the same type.
pub fn mapSetData(self: *const ZAPI, map: ?*Map, key: [:0]const u8, data: [:0]const u8, dth: DataTypeHint, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetData.?(map, key.ptr, data.ptr, @intCast(data.len), dth, mode);
}
/// Retrieves a node from a map. Returns a pointer to the node on success, or NULL in case of error.
/// This function increases the node’s reference count, so freeNode() must be used when the node is no longer needed.
pub fn mapGetNode(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) ?*Node {
    return self.vsapi.mapGetNode.?(map, key.ptr, index, err);
}
/// Sets a node to the specified key in a map.
pub fn mapSetNode(self: *const ZAPI, map: ?*Map, key: [:0]const u8, node: ?*Node, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetNode.?(map, key.ptr, node, mode);
}
/// Sets a node to the specified key in a map and decreases the reference count.
pub fn mapConsumeNode(self: *const ZAPI, map: ?*Map, key: [:0]const u8, node: ?*Node, mode: MapAppendMode) i32 {
    return self.vsapi.mapConsumeNode.?(map, key.ptr, node, mode);
}
/// Retrieves a frame from a map. Returns a pointer to the frame on success, or NULL in case of error.
/// This function increases the frame’s reference count, so freeFrame() must be used when the frame is no longer needed.
pub fn mapGetFrame(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) ?*Frame {
    return self.vsapi.mapGetFrame.?(map, key.ptr, index, err);
}
/// Sets a frame to the specified key in a map.
pub fn mapSetFrame(self: *const ZAPI, map: ?*Map, key: [:0]const u8, frame: ?*Frame, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetFrame.?(map, key.ptr, frame, mode);
}
/// Sets a frame to the specified key in a map and decreases the reference count.
pub fn mapConsumeFrame(self: *const ZAPI, map: ?*Map, key: [:0]const u8, frame: ?*Frame, mode: MapAppendMode) i32 {
    return self.vsapi.mapConsumeFrame.?(map, key.ptr, frame, mode);
}
/// Retrieves a function from a map. Returns a pointer to the function on success, or NULL in case of error.
/// This function increases the function’s reference count, so freeFunction() must be used when the function is no longer needed.
pub fn mapGetFunction(self: *const ZAPI, map: ?*const Map, key: [:0]const u8, index: i32, err: ?*MapPropertyError) ?*Function {
    return self.vsapi.mapGetFunction.?(map, key.ptr, index, err);
}
/// Sets a function object to the specified key in a map.
pub fn mapSetFunction(self: *const ZAPI, map: ?*Map, key: [:0]const u8, func: ?*Function, mode: MapAppendMode) i32 {
    return self.vsapi.mapSetFunction.?(map, key.ptr, func, mode);
}
/// Sets a function object to the specified key in a map and decreases the reference count.
pub fn mapConsumeFunction(self: *const ZAPI, map: ?*Map, key: [:0]const u8, func: ?*Function, mode: MapAppendMode) i32 {
    return self.vsapi.mapConsumeFunction.?(map, key.ptr, func, mode);
}
/// Function that registers a filter exported by the plugin. A plugin can export any number of filters.
/// This function may only be called during the plugin loading phase unless the pcModifiable flag was set by configPlugin.
pub fn registerFunction(self: *const ZAPI, name: [:0]const u8, args: [:0]const u8, return_type: [:0]const u8, func: PublicFunction, data: ?*anyopaque, plugin: ?*Plugin) i32 {
    return self.vsapi.registerFunction.?(name.ptr, args.ptr, return_type.ptr, func, data, plugin);
}
/// Returns a pointer to the plugin with the given identifier, or NULL if not found.
pub fn getPluginByID(self: *const ZAPI, identifier: [:0]const u8, core: ?*Core) ?*Plugin {
    return self.vsapi.getPluginByID.?(identifier.ptr, core);
}
/// Returns a pointer to the plugin with the given identifier, or NULL if not found.
/// Wrapper around getPluginByID() that takes a PluginID instead of a string.
pub fn getPluginByID2(self: *const ZAPI, id: vsh.PluginID, core: ?*Core) ?*Plugin {
    return self.vsapi.getPluginByID.?(id.toString().ptr, core);
}
/// Returns a pointer to the plugin with the given namespace, or NULL if not found.
pub fn getPluginByNamespace(self: *const ZAPI, ns: [:0]const u8, core: ?*Core) ?*Plugin {
    return self.vsapi.getPluginByNamespace.?(ns.ptr, core);
}
/// Used to enumerate over all currently loaded plugins. The order is fixed but provides no other guarantees.
pub fn getNextPlugin(self: *const ZAPI, plugin: ?*Plugin, core: ?*Core) ?*Plugin {
    return self.vsapi.getNextPlugin.?(plugin, core);
}
/// Returns the name of the plugin that was passed to configPlugin.
pub fn getPluginName(self: *const ZAPI, plugin: ?*Plugin) ?[*]const u8 {
    return self.vsapi.getPluginName.?(plugin);
}
/// Returns the identifier of the plugin that was passed to configPlugin.
pub fn getPluginID(self: *const ZAPI, plugin: ?*Plugin) ?[*]const u8 {
    return self.vsapi.getPluginID.?(plugin);
}
/// Returns the namespace the plugin currently is loaded in.
pub fn getPluginNamespace(self: *const ZAPI, plugin: ?*Plugin) ?[*]const u8 {
    return self.vsapi.getPluginNamespace.?(plugin);
}
/// Used to enumerate over all functions in a plugin. The order is fixed but provides no other guarantees.
pub fn getNextPluginFunction(self: *const ZAPI, func: ?*PluginFunction, plugin: ?*Plugin) ?*PluginFunction {
    return self.vsapi.getNextPluginFunction.?(func, plugin);
}
/// Get a function belonging to a plugin by its name.
pub fn getPluginFunctionByName(self: *const ZAPI, name: [:0]const u8, plugin: ?*Plugin) ?*PluginFunction {
    return self.vsapi.getPluginFunctionByName.?(name.ptr, plugin);
}
/// Returns the name of the function that was passed to registerFunction.
pub fn getPluginFunctionName(self: *const ZAPI, func: ?*PluginFunction) ?[*]const u8 {
    return self.vsapi.getPluginFunctionName.?(func);
}
/// Returns the argument string of the function that was passed to registerFunction.
pub fn getPluginFunctionArguments(self: *const ZAPI, func: ?*PluginFunction) ?[*]const u8 {
    return self.vsapi.getPluginFunctionArguments.?(func);
}
/// Returns the return type string of the function that was passed to registerFunction.
pub fn getPluginFunctionReturnType(self: *const ZAPI, func: ?*PluginFunction) ?[*]const u8 {
    return self.vsapi.getPluginFunctionReturnType.?(func);
}
/// Returns the absolute path to the plugin, including the plugin’s file name. This is the real location of the plugin, i.e. there are no symbolic links in the path.
pub fn getPluginPath(self: *const ZAPI, plugin: ?*const Plugin) ?[*]const u8 {
    return self.vsapi.getPluginPath.?(plugin);
}
/// Returns the version of the plugin. This is the same as the version number passed to configPlugin.
pub fn getPluginVersion(self: *const ZAPI, plugin: ?*const Plugin) i32 {
    return self.vsapi.getPluginVersion.?(plugin);
}
/// Checks that the args passed to the filter are consistent with the argument list registered by the plugin that contains the filter, calls the filter’s
/// “create” function, and checks that the filter returns the declared types. If everything goes smoothly, the filter will be ready to generate frames after invoke() returns.
pub fn invoke(self: *const ZAPI, plugin: ?*Plugin, args: [:0]const u8, in: ?*const Map) ?*Map {
    return self.vsapi.invoke.?(plugin, args.ptr, in);
}
/// Creates the VapourSynth processing core and returns a pointer to it. It is possible to create multiple cores but in most cases it shouldn’t be needed.
pub fn createCore(self: *const ZAPI, flags: CoreCreationFlags) ?*Core {
    return self.vsapi.createCore.?(flags);
}
/// Frees a core. Should only be done after all frame requests have completed and all objects belonging to the core have been released.
pub fn freeCore(self: *const ZAPI, core: ?*Core) void {
    self.vsapi.freeCore.?(core);
}
/// Sets the maximum size of the framebuffer cache. Returns the new maximum size.
pub fn setMaxCacheSize(self: *const ZAPI, bytes: i64, core: ?*Core) i64 {
    return self.vsapi.setMaxCacheSize.?(bytes, core);
}
/// Sets the number of threads used for processing. Pass 0 to automatically detect. Returns the number of threads that will be used for processing.
pub fn setThreadCount(self: *const ZAPI, threads: i32, core: ?*Core) i32 {
    return self.vsapi.setThreadCount.?(threads, core);
}
/// Returns information about the VapourSynth core.
pub fn getCoreInfo(self: *const ZAPI, core: ?*Core, info: *CoreInfo) void {
    self.vsapi.getCoreInfo.?(core, info);
}
/// Returns the highest VAPOURSYNTH_API_VERSION the library support.
pub fn getAPIVersion(self: *const ZAPI) i32 {
    return self.vsapi.getAPIVersion.?();
}
/// Send a message through VapourSynth’s logging framework. See addLogHandler.
pub fn logMessage(self: *const ZAPI, mt: MessageType, msg: [:0]const u8, core: ?*Core) void {
    self.vsapi.logMessage.?(mt, msg.ptr, core);
}
/// Installs a custom handler for the various error messages VapourSynth emits. The message handler is per VSCore instance. Returns a unique handle.
pub fn addLogHandler(self: *const ZAPI, handler: LogHandler, free: LogHandlerFree, user_data: ?*anyopaque, core: ?*Core) ?*LogHandle {
    return self.vsapi.addLogHandler.?(handler, free, user_data, core);
}
/// Removes a custom handler. Return non-zero on success and zero if the handle is invalid.
pub fn removeLogHandler(self: *const ZAPI, handle: ?*LogHandle, core: ?*Core) i32 {
    return self.vsapi.removeLogHandler.?(handle, core);
}

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
