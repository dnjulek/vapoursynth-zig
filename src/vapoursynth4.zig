//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VapourSynth4.h

/// Used to create version numbers.
pub inline fn makeVersion(major: c_int, minor: c_int) c_int {
    return (major << @as(c_int, 16)) | minor;
}

/// Major API version.
pub const VAPOURSYNTH_API_MAJOR: c_int = 4;
/// Minor API version. It is bumped when new functions are added to API or core behavior is noticeably changed.
pub const VAPOURSYNTH_API_MINOR: c_int = 0;
/// API version. The high 16 bits are VAPOURSYNTH_API_MAJOR, the low 16 bits are VAPOURSYNTH_API_MINOR.
pub const VAPOURSYNTH_API_VERSION: c_int = makeVersion(VAPOURSYNTH_API_MAJOR, VAPOURSYNTH_API_MINOR);
/// The number of audio samples in an audio frame. It is a static number to make it possible to calculate which audio frames are needed to retrieve specific samples.
pub const AUDIO_FRAME_SAMPLES: c_int = 3072;
/// A frame that can hold audio or video data. Each row of pixels in a frame is guaranteed to have an alignment of at least 32 bytes.
/// Two frames with the same width and bytes per sample are guaranteed to have the same stride. Audio data is also guaranteed to be at least 32 byte aligned. Any data can be attached to a frame, using a VSMap.
pub const Frame = opaque {};
/// A reference to a node in the constructed filter graph. Its primary use is as an argument to other filter or to request frames from.
pub const Node = opaque {};
/// The core represents one instance of VapourSynth. Every core individually loads plugins and keeps track of memory.
pub const Core = opaque {};
/// A VapourSynth plugin. There are a few of these built into the core, and therefore available at all times: the basic filters (identifier: [*]const u8 com.vapoursynth.std, namespace std),
/// the resizers (identifier: [*]const u8 com.vapoursynth.resize, namespace resize), and the Avisynth compatibility module, if running in Windows (identifier: [*]const u8 com.vapoursynth.avisynth, namespace avs).
pub const Plugin = opaque {};
/// A function belonging to a Vapoursynth plugin. This object primarily exists so a plugin’s name, argument list and return type can be queried by editors.
/// One peculiarity is that plugin functions cannot be invoked using a VSPluginFunction pointer but is instead done using invoke() which takes a VSPlugin and the function name as a string.
pub const PluginFunction = opaque {};
/// Holds a reference to a function that may be called. This type primarily exists so functions can be shared between the scripting layer and plugins in the core.
pub const Function = opaque {};
/// VSMap is a container that stores (key,value) pairs. The keys are strings and the values can be (arrays of) integers, floating point numbers, arrays of bytes, VSNode, VSFrame, or VSFunction. The pairs in a VSMap are sorted by key.
pub const Map = opaque {};
/// Opaque type representing a registered logger.
pub const LogHandle = opaque {};
/// Opaque type representing the current frame request in a filter.
pub const FrameContext = opaque {};

pub const ColorFamily = enum(c_int) {
    Undefined = 0,
    Gray = 1,
    RGB = 2,
    YUV = 3,
};

pub const SampleType = enum(c_int) {
    Integer = 0,
    Float = 1,
};

pub inline fn makeVideoID(color_family: ColorFamily, sample_type: SampleType, bits_per_sample: c_int, sub_sampling_w: c_int, sub_sampling_h: c_int) PresetVideoFormat {
    return ((color_family << 28) | (sample_type << 24) | (bits_per_sample << 16) | (sub_sampling_w << 8) | (sub_sampling_h << 0));
}

/// The presets suffixed with H and S have floating point sample type. The H and S suffixes stand for half precision and single precision, respectively.
/// All formats are planar. See the header for all currently defined video format presets.
pub const PresetVideoFormat = enum(c_int) {
    None = 0,

    Gray8 = makeVideoID(.Gray, .Integer, 8, 0, 0),
    Gray9 = makeVideoID(.Gray, .Integer, 9, 0, 0),
    Gray10 = makeVideoID(.Gray, .Integer, 10, 0, 0),
    Gray12 = makeVideoID(.Gray, .Integer, 12, 0, 0),
    Gray14 = makeVideoID(.Gray, .Integer, 14, 0, 0),
    Gray16 = makeVideoID(.Gray, .Integer, 16, 0, 0),
    Gray32 = makeVideoID(.Gray, .Integer, 32, 0, 0),

    GrayH = makeVideoID(.Gray, .Float, 16, 0, 0),
    GrayS = makeVideoID(.Gray, .Float, 32, 0, 0),

    YUV410P8 = makeVideoID(.YUV, .Integer, 8, 2, 2),
    YUV411P8 = makeVideoID(.YUV, .Integer, 8, 2, 0),
    YUV440P8 = makeVideoID(.YUV, .Integer, 8, 0, 1),

    YUV420P8 = makeVideoID(.YUV, .Integer, 8, 1, 1),
    YUV422P8 = makeVideoID(.YUV, .Integer, 8, 1, 0),
    YUV444P8 = makeVideoID(.YUV, .Integer, 8, 0, 0),

    YUV420P9 = makeVideoID(.YUV, .Integer, 9, 1, 1),
    YUV422P9 = makeVideoID(.YUV, .Integer, 9, 1, 0),
    YUV444P9 = makeVideoID(.YUV, .Integer, 9, 0, 0),

    YUV420P10 = makeVideoID(.YUV, .Integer, 10, 1, 1),
    YUV422P10 = makeVideoID(.YUV, .Integer, 10, 1, 0),
    YUV444P10 = makeVideoID(.YUV, .Integer, 10, 0, 0),

    YUV420P12 = makeVideoID(.YUV, .Integer, 12, 1, 1),
    YUV422P12 = makeVideoID(.YUV, .Integer, 12, 1, 0),
    YUV444P12 = makeVideoID(.YUV, .Integer, 12, 0, 0),

    YUV420P14 = makeVideoID(.YUV, .Integer, 14, 1, 1),
    YUV422P14 = makeVideoID(.YUV, .Integer, 14, 1, 0),
    YUV444P14 = makeVideoID(.YUV, .Integer, 14, 0, 0),

    YUV420P16 = makeVideoID(.YUV, .Integer, 16, 1, 1),
    YUV422P16 = makeVideoID(.YUV, .Integer, 16, 1, 0),
    YUV444P16 = makeVideoID(.YUV, .Integer, 16, 0, 0),

    YUV444PH = makeVideoID(.YUV, .Float, 16, 0, 0),
    YUV444PS = makeVideoID(.YUV, .Float, 32, 0, 0),

    RGB24 = makeVideoID(.RGB, .Integer, 8, 0, 0),
    RGB27 = makeVideoID(.RGB, .Integer, 9, 0, 0),
    RGB30 = makeVideoID(.RGB, .Integer, 10, 0, 0),
    RGB36 = makeVideoID(.RGB, .Integer, 12, 0, 0),
    RGB42 = makeVideoID(.RGB, .Integer, 14, 0, 0),
    RGB48 = makeVideoID(.RGB, .Integer, 16, 0, 0),

    RGBH = makeVideoID(.RGB, .Float, 16, 0, 0),
    RGBS = makeVideoID(.RGB, .Float, 32, 0, 0),
};

/// Controls how a filter will be multithreaded, if at all.
pub const FilterMode = enum(c_int) {
    /// Completely parallel execution. Multiple threads will call a filter’s “getframe” function, to fetch several frames in parallel.
    Parallel = 0,
    /// For filters that are serial in nature but can request in advance one or more frames they need. A filter’s “getframe” function will be called
    /// from multiple threads at a time with activation reason arInitial, but only one thread will call it with activation reason arAllFramesReady at a time.
    ParallelRequests = 1,
    /// Only one thread can call the filter’s “getframe” function at a time. Useful for filters that modify or examine their internal state to determine which frames to request.
    /// While the “getframe” function will only run in one thread at a time, the calls can happen in any order. For example, it can be called with reason arInitial for frame 0,
    /// then again with reason arInitial for frame 1, then with reason arAllFramesReady for frame 0.
    Unordered = 2,
    /// For compatibility with other filtering architectures. DO NOT USE IN NEW FILTERS. The filter’s “getframe” function only ever gets called from one thread at a time.
    /// Unlike fmUnordered, only one frame is processed at a time.
    FrameState = 3,
};

/// Used to indicate the type of a VSFrame or VSNode object.
pub const MediaType = enum(c_int) {
    Video = 1,
    Audio = 2,
};

/// Describes the format of a clip.
/// Use queryVideoFormat() to fill it in with proper error checking. Manually filling out the struct is allowed but discouraged since illegal combinations of values will cause undefined behavior.
pub const VideoFormat = extern struct {
    colorFamily: ColorFamily,
    sampleType: SampleType,
    /// Number of significant bits.
    bitsPerSample: c_int,
    /// Number of bytes needed for a sample. This is always a power of 2 and the smallest possible that can fit the number of bits used per sample.
    bytesPerSample: c_int,
    /// log2 subsampling factor, applied to second and third plane
    subSamplingW: c_int,
    /// log2 subsampling factor, applied to second and third plane
    subSamplingH: c_int,
    /// implicit from colorFamily
    numPlanes: c_int,
};

/// Audio channel positions as an enum. Mirrors the FFmpeg audio channel constants in older api versions. See the header for all available values.
pub const AudioChannels = enum(c_int) {
    FrontLeft = 0,
    FrontRight = 1,
    FrontCenter = 2,
    LowFrequency = 3,
    BackLeft = 4,
    BackRight = 5,
    FrontLeftOFCenter = 6,
    FrontRightOFCenter = 7,
    BackCenter = 8,
    SideLeft = 9,
    SideRight = 10,
    TopCenter = 11,
    TopFrontLeft = 12,
    TopFrontCenter = 13,
    TopFrontRight = 14,
    TopBackLeft = 15,
    TopBackCenter = 16,
    TopBackRight = 17,
    StereoLeft = 29,
    StereoRight = 30,
    WideLeft = 31,
    WideRight = 32,
    SurroundDirectLeft = 33,
    SurroundDirectRight = 34,
    LowFrequency2 = 35,
};

/// Describes the format of a clip.
/// Use queryAudioFormat() to fill it in with proper error checking. Manually filling out the struct is allowed but discouraged since illegal combinations of values will cause undefined behavior.
pub const AudioFormat = extern struct {
    sampleType: SampleType,
    bitsPerSample: c_int,
    /// Number of bytes needed for a sample. This is always a power of 2 and the smallest possible that can fit the number of bits used per sample.
    bytesPerSample: c_int,
    /// implicit from channelLayout
    numChannels: c_int,
    /// A bitmask representing the channels present using the constants in 1 left shifted by the constants in VSAudioChannels.
    channelLayout: u64,
};

/// Types of properties that can be stored in a VSMap.
pub const PropertyType = enum(c_int) {
    Unset = 0,
    Int = 1,
    Float = 2,
    Data = 3,
    Function = 4,
    VideoNode = 5,
    AudioNode = 6,
    VideoFrame = 7,
    AudioFrame = 8,
};

/// When a mapGet* function fails, it returns one of these in the err parameter.
pub const MapPropertyError = enum(c_int) {
    Success = 0,
    /// no key exists
    Unset = 1,
    /// key exists but not of a compatible type
    Type = 2,
    /// index out of bounds
    Index = 4,
    /// map has error state set
    Error = 3,
};

/// Controls the behaviour of mapSetInt() and friends.
pub const MapAppendMode = enum(c_int) {
    Replace = 0,
    Append = 1,
};

/// Contains information about a VSCore instance.
pub const CoreInfo = extern struct {
    versionString: [*]const u8,
    core: c_int,
    api: c_int,
    numThreads: c_int,
    maxFramebufferSize: i64,
    usedFramebufferSize: i64,
};

/// Contains information about a clip.
pub const VideoInfo = extern struct {
    /// Format of the clip. Will have colorFamily set to cfUndefined if the format can vary.
    format: VideoFormat,
    /// Numerator part of the clip’s frame rate. It will be 0 if the frame rate can vary. Should always be a reduced fraction.
    fpsNum: i64,
    /// Denominator part of the clip’s frame rate. It will be 0 if the frame rate can vary. Should always be a reduced fraction.
    fpsDen: i64,
    /// Width of the clip. Both width and height will be 0 if the clip’s dimensions can vary.
    width: c_int,
    /// Height of the clip. Both width and height will be 0 if the clip’s dimensions can vary.
    height: c_int,
    /// Length of the clip.
    numFrames: c_int,
};

/// Contains information about a clip.
pub const AudioInfo = extern struct {
    /// Format of the clip. Unlike video the audio format can never change.
    format: AudioFormat,
    sampleRate: c_int,
    /// Length of the clip in audio samples.
    numSamples: i64,
    /// the total number of audio frames needed to hold numSamples, implicit from numSamples when calling createAudioFilter
    numFrames: c_int,
};

/// See FilterGetFrame.
pub const ActivationReason = enum(c_int) {
    Initial = 0,
    AllFramesReady = 1,
    Error = -1,
};

/// See addLogHandler().
pub const MessageType = enum(c_int) {
    Debug = 0,
    Information = 1,
    Warning = 2,
    Critical = 3,
    /// also terminates the process, should generally not be used by normal filters
    Fatal = 4,
};

/// Options when creating a core.
pub const CoreCreationFlags = enum(c_int) {
    /// Required to use the graph inspection api functions. Increases memory usage due to the extra information stored.
    EnableGraphInspection = 1,
    /// Don’t autoload any user plugins. Core plugins are always loaded.
    DisableAutoLoading = 2,
    /// Don’t unload plugin libraries when the core is destroyed. Due to a small amount of memory leaking every load and unload
    /// (windows feature, not my fault) of a library this may help in applications with extreme amount of script reloading.
    DisableLibraryUnloading = 4,
};

/// Options when loading a plugin.
pub const PluginConfigFlags = enum(c_int) {
    Unmodifiable = 0,
    /// Allow functions to be added to the plugin object after the plugin loading phase. Mostly useful for Avisynth compatibility and other foreign plugin loaders.
    Modifiable = 1,
};

/// Since the data type can contain both pure binary data and printable strings the type also contains a hint for whether or not it is human readable.
/// Generally the unknown type should be very rare and is almost only created as an artifact of API3 compatibility.
pub const DataTypeHint = enum(c_int) {
    Unknown = -1,
    Binary = 0,
    Utf8 = 1,
};

/// Describes the upstream frame request pattern of a filter.
pub const RequestPattern = enum(c_int) {
    /// Anything goes. Note that filters that may be requesting beyond the end of a VSNode length in frames (repeating the last frame) should use rpGeneral and not any of the other modes.
    General = 0,
    /// Will only request an input frame at most once if all output frames are requested exactly one time. This includes filters such as Trim, Reverse, SelectEvery.
    NoFrameReuse = 1,
    /// Only requests frame N to output frame N. The main difference to rpNoFrameReuse is that the requested frame is always fixed and known ahead of time.
    /// Filter examples Lut, Expr (conditionally, see rpGeneral note) and similar.
    StrictSpatial = 2,
};

/// Describes how the output of a node is cached.
pub const CacheMode = enum(c_int) {
    /// Cache is enabled or disabled based on the reported request patterns and number of consumers.
    Auto = -1,
    /// Never cache anything.
    ForceDisable = 0,
    /// Always use the cache.
    ForceEnable = 1,
};

/// Returns a pointer to the global VSAPI instance.
/// Returns NULL if the requested API version is not supported or if the system does not meet the minimum requirements to run VapourSynth. It is recommended to pass VAPOURSYNTH_API_VERSION.
pub const GetVapourSynthAPI = ?*const fn (c_int) callconv(.C) *const API;
/// User-defined function called by the core to create an instance of the filter. This function is often named fooCreate.
/// In this function, the filter’s input parameters should be retrieved and validated, the filter’s private instance data should be initialised,
/// and createAudioFilter() or createVideoFilter() should be called. This is where the filter should perform any other initialisation it requires.
/// If for some reason you cannot create the filter, you have to free any created node references using freeNode(), call mapSetError() on out, and return.
pub const PublicFunction = ?*const fn (?*const Map, ?*Map, userData: ?*anyopaque, ?*Core, *const API) callconv(.C) void;
/// Same as PublicFunction type, required to use registerFunction in separate zig file without dependency loop error.
pub const PublicFunction2 = ?*const fn (?*const Map, ?*Map, userData: ?*anyopaque, ?*Core, *const API) callconv(.C) void;
/// A plugin’s entry point. It must be called VapourSynthPluginInit2. This function is called after the core loads the shared library. Its purpose is to configure the plugin and to register the filters the plugin wants to export.
pub const InitPlugin = ?*const fn (?*Plugin, *const PLUGINAPI) callconv(.C) void;
pub const FreeFunctionData = ?*const fn (?*anyopaque) callconv(.C) void;
/// A filter’s “getframe” function. It is called by the core when it needs the filter to generate a frame.
pub const FilterGetFrame = ?*const fn (n: c_int, ActivationReason, instanceData: ?*anyopaque, frameData: *?*anyopaque, ?*FrameContext, ?*Core, *const API) callconv(.C) ?*const Frame;
/// This is where the filter should free everything it allocated, including its instance data.
pub const FilterFree = ?*const fn (?*anyopaque, ?*Core, *const API) callconv(.C) void;

/// Requests the generation of a frame. When the frame is ready, a user-provided function is called. Note that the completion callback will only be called from a single thread at a time.
pub const FrameDoneCallback = ?*const fn (?*anyopaque, ?*const Frame, n: c_int, ?*Node, [*]const u8) callconv(.C) void;
/// Custom message handler.
pub const LogHandler = ?*const fn (MessageType, [*]const u8, userData: ?*anyopaque) callconv(.C) void;
/// Called when a handler is removed.
pub const LogHandlerFree = ?*const fn (userData: ?*anyopaque) callconv(.C) void;

/// This struct is used to access VapourSynth’s API when a plugin is initially loaded.
pub const PLUGINAPI = extern struct {
    /// returns VAPOURSYNTH_API_VERSION of the library
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    /// Used to provide information about a plugin when loaded. Must be called exactly once from the VapourSynthPluginInit2 entry point. It is recommended to use the makeVersion fn when providing the pluginVersion.
    configPlugin: ?*const fn (identifier: [*]const u8, pluginNamespace: [*]const u8, name: [*]const u8, pluginVersion: c_int, apiVersion: c_int, flag: c_int, ?*Plugin) callconv(.C) c_int,
    /// Function that registers a filter exported by the plugin. A plugin can export any number of filters. This function may only be called during the plugin loading phase unless the pcModifiable flag was set by configPlugin.
    registerFunction: ?*const fn (name: [*]const u8, args: [*]const u8, returnType: [*]const u8, argsFunc: PublicFunction2, functionData: ?*anyopaque, ?*Plugin) callconv(.C) c_int,
};

/// Contains information about a VSCore instance.
pub const FilterDependency = extern struct {
    /// The node frames are requested from.
    source: ?*Node,
    requestPattern: RequestPattern,
};

/// This giant struct is the way to access VapourSynth’s public API.
pub const API = extern struct {
    /// output nodes are appended to the clip key in the out map
    createVideoFilter: ?*const fn (out: ?*Map, name: [*]const u8, vi: *const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, numDeps: c_int, instanceData: ?*anyopaque, ?*Core) callconv(.C) void,
    /// same as createVideoFilter but returns a pointer to the VSNode directly or NULL on failure
    createVideoFilter2: ?*const fn (name: [*]const u8, vi: *const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, numDeps: c_int, instanceData: ?*anyopaque, ?*Core) callconv(.C) ?*Node,
    /// output nodes are appended to the clip key in the out map
    createAudioFilter: ?*const fn (out: ?*Map, name: [*]const u8, *const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, numDeps: c_int, instanceData: ?*anyopaque, ?*Core) callconv(.C) void,
    /// same as createAudioFilter but returns a pointer to the VSNode directly or NULL on failure
    createAudioFilter2: ?*const fn (name: [*]const u8, *const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, numDeps: c_int, instanceData: ?*anyopaque, ?*Core) callconv(.C) ?*Node,
    /// Use right after create*Filter*, sets the correct cache mode for using the cacheFrame API and returns the recommended upper number of additional frames to cache per request
    setLinearFilter: ?*const fn (?*Node) callconv(.C) c_int,
    /// VSCacheMode, changing the cache mode also resets all options to their default
    setCacheMode: ?*const fn (?*Node, CacheMode) callconv(.C) void,
    /// passing -1 means no change
    setCacheOptions: ?*const fn (?*Node, fixedSize: c_int, maxSize: c_int, maxHistorySize: c_int) callconv(.C) void,
    /// Decreases the reference count of a node and destroys it once it reaches 0.
    freeNode: ?*const fn (?*Node) callconv(.C) void,
    /// Increment the reference count of a node. Returns the same node for convenience.
    addNodeRef: ?*const fn (?*Node) callconv(.C) ?*Node,
    /// Returns VSMediaType. Used to determine if a node is of audio or video type.
    getNodeType: ?*const fn (?*Node) callconv(.C) MediaType,
    /// Returns a pointer to the video info associated with a node. The pointer is valid as long as the node lives. It is undefined behavior to pass a non-video node.
    getVideoInfo: ?*const fn (?*Node) callconv(.C) *const VideoInfo,
    /// Returns a pointer to the audio info associated with a node. The pointer is valid as long as the node lives. It is undefined behavior to pass a non-audio node.
    getAudioInfo: ?*const fn (?*Node) callconv(.C) *const AudioInfo,
    /// Creates a new video frame, optionally copying the properties attached to another frame. It is a fatal error to pass invalid arguments to this function.
    /// The new frame contains uninitialised memory.
    newVideoFrame: ?*const fn (*const VideoFormat, width: c_int, height: c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    /// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
    newVideoFrame2: ?*const fn (*const VideoFormat, width: c_int, height: c_int, [*]?*const Frame, plane: [*]const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    /// Creates a new audio frame, optionally copying the properties attached to another frame. It is a fatal error to pass invalid arguments to this function.
    /// The new frame contains uninitialised memory.
    newAudioFrame: ?*const fn (*const AudioFormat, numSamples: c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    /// same as newAudioFrame but allows the specified channels to be effectively copied from the source frames
    newAudioFrame2: ?*const fn (*const AudioFormat, numSamples: c_int, *?*const Frame, *const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    /// Decrements the reference count of a frame and deletes it when it reaches 0.
    freeFrame: ?*const fn (?*const Frame) callconv(.C) void,
    /// Increments the reference count of a frame. Returns f as a convenience.
    addFrameRef: ?*const fn (?*const Frame) callconv(.C) ?*const Frame,
    /// Duplicates the frame (not just the reference). As the frame buffer is shared in a copy-on-write fashion, the frame content is not really duplicated until a write operation occurs. This is transparent for the user.
    /// Returns a pointer to the new frame. Ownership is transferred to the caller.
    copyFrame: ?*const fn (?*const Frame, ?*Core) callconv(.C) ?*Frame,
    /// Returns a read-only pointer to a frame’s properties. The pointer is valid as long as the frame lives.
    getFramePropertiesRO: ?*const fn (?*const Frame) callconv(.C) ?*const Map,
    /// Returns a read/write pointer to a frame’s properties. The pointer is valid as long as the frame lives.
    getFramePropertiesRW: ?*const fn (?*Frame) callconv(.C) ?*Map,
    /// Returns the distance in bytes between two consecutive lines of a plane of a video frame. The stride is always positive. Returns 0 if the requested plane doesn’t exist or if it isn’t a video frame.
    getStride: ?*const fn (?*const Frame, plane: c_int) callconv(.C) c_longlong,
    /// Returns a read-only pointer to a plane or channel of a frame. Returns NULL if an invalid plane or channel number is passed.
    /// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
    getReadPtr: ?*const fn (?*const Frame, plane: c_int) callconv(.C) [*]const u8,
    /// Returns a read-write pointer to a plane or channel of a frame. Returns NULL if an invalid plane or channel number is passed.
    /// Don’t assume all three planes of a frame are allocated in one contiguous chunk (they’re not).
    getWritePtr: ?*const fn (?*Frame, plane: c_int) callconv(.C) [*]u8,
    /// Retrieves the format of a video frame.
    getVideoFrameFormat: ?*const fn (?*const Frame) callconv(.C) *const VideoFormat,
    /// Retrieves the format of an audio frame.
    getAudioFrameFormat: ?*const fn (?*const Frame) callconv(.C) *const AudioFormat,
    /// Returns a value from VSMediaType to distinguish audio and video frames.
    getFrameType: ?*const fn (?*const Frame) callconv(.C) MediaType,
    /// Returns the width of a plane of a given video frame, in pixels. The width depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
    getFrameWidth: ?*const fn (?*const Frame, plane: c_int) callconv(.C) c_int,
    /// Returns the height of a plane of a given video frame, in pixels. The height depends on the plane number because of the possible chroma subsampling. Returns 0 for audio frames.
    getFrameHeight: ?*const fn (?*const Frame, plane: c_int) callconv(.C) c_int,
    /// Returns the number of audio samples in a frame. Always returns 1 for video frames.
    getFrameLength: ?*const fn (?*const Frame) callconv(.C) c_int,
    /// Tries to output a fairly human-readable name of a video format.
    /// [*]u8: Destination buffer. At most 32 bytes including terminating NULL will be written.
    getVideoFormatName: ?*const fn (*const VideoFormat, [*]u8) callconv(.C) c_int,
    /// Tries to output a fairly human-readable name of an audio format.
    /// [*]u8: Destination buffer. At most 32 bytes including terminating NULL will be written.
    getAudioFormatName: ?*const fn (*const AudioFormat, [*]u8) callconv(.C) c_int,
    /// Fills out a VSVideoInfo struct based on the provided arguments. Validates the arguments before filling out format.
    queryVideoFormat: ?*const fn (*VideoFormat, ColorFamily, SampleType, bitsPerSample: c_int, subSamplingW: c_int, subSamplingH: c_int, ?*Core) callconv(.C) c_int,
    /// Fills out a VSAudioFormat struct based on the provided arguments. Validates the arguments before filling out format.
    queryAudioFormat: ?*const fn (*AudioFormat, SampleType, bitsPerSample: c_int, channelLayout: u64, ?*Core) callconv(.C) c_int,
    /// Get the id associated with a video format. Similar to queryVideoFormat() except that it returns a format id instead of filling out a VSVideoInfo struct.
    queryVideoFormatID: ?*const fn (ColorFamily, SampleType, bitsPerSample: c_int, subSamplingW: c_int, subSamplingH: c_int, ?*Core) callconv(.C) u32,
    /// Fills out the VSVideoFormat struct passed to format based
    getVideoFormatByID: ?*const fn (*VideoFormat, id: u32, ?*Core) callconv(.C) c_int,
    /// Fetches a frame synchronously. The frame is available when the function returns.
    /// This function is meant for external applications using the core as a library, or if frame requests are necessary during a filter’s initialization.
    getFrame: ?*const fn (n: c_int, ?*Node, errorMsg: [*]const u8, bufSize: c_int) callconv(.C) ?*const Frame,
    /// Requests the generation of a frame. When the frame is ready, a user-provided function is called. Note that the completion callback will only be called from a single thread at a time.
    /// This function is meant for applications using VapourSynth as a library.
    getFrameAsync: ?*const fn (n: c_int, ?*Node, FrameDoneCallback, userData: ?*anyopaque) callconv(.C) void,
    /// Retrieves a frame that was previously requested with requestFrameFilter(). Only use inside a filter's getframe function
    getFrameFilter: ?*const fn (n: c_int, ?*Node, ?*FrameContext) callconv(.C) ?*const Frame,
    /// Requests a frame from a node and returns immediately. Only use inside a filter's getframe function
    requestFrameFilter: ?*const fn (n: c_int, ?*Node, ?*FrameContext) callconv(.C) void,
    /// By default all requested frames are referenced until a filter’s frame request is done. In extreme cases where a filter needs to reduce 20+ frames
    /// into a single output frame it may be beneficial to request these in batches and incrementally process the data instead.
    releaseFrameEarly: ?*const fn (?*Node, n: c_int, ?*FrameContext) callconv(.C) void,
    /// Pushes a not requested frame into the cache. This is useful for (source) filters that greatly benefit from completely linear access and producing all output in linear order.
    /// This function may only be used in filters that were created with setLinearFilter.
    cacheFrame: ?*const fn (?*const Frame, n: c_int, ?*FrameContext) callconv(.C) void,
    /// Adds an error message to a frame context, replacing the existing message, if any.
    /// This is the way to report errors in a filter’s “getframe” function. Such errors are not necessarily fatal, i.e. the caller can try to request the same frame again.
    setFilterError: ?*const fn (errorMessage: [*]const u8, ?*FrameContext) callconv(.C) void,
    // External functions
    createFunction: ?*const fn (PublicFunction, userData: ?*anyopaque, FreeFunctionData, ?*Core) callconv(.C) ?*Function,
    /// Decrements the reference count of a function and deletes it when it reaches 0.
    freeFunction: ?*const fn (?*Function) callconv(.C) void,
    addFunctionRef: ?*const fn (?*Function) callconv(.C) ?*Function,
    callFunction: ?*const fn (?*Function, ?*const Map, ?*Map) callconv(.C) void,
    /// Creates a new property map. It must be deallocated later with freeMap().
    createMap: ?*const fn () callconv(.C) ?*Map,
    /// Frees a map and all the objects it contains.
    freeMap: ?*const fn (?*Map) callconv(.C) void,
    /// Deletes all the keys and their associated values from the map, leaving it empty.
    clearMap: ?*const fn (?*Map) callconv(.C) void,
    /// copies all values in src to dst, if a key already exists in dst it's replaced
    copyMap: ?*const fn (?*const Map, ?*Map) callconv(.C) void,
    /// Adds an error message to a map. The map is cleared first. The error message is copied. In this state the map may only be freed, cleared or queried for the error message.
    /// For errors encountered in a filter’s “getframe” function, use setFilterError.
    mapSetError: ?*const fn (?*Map, errorMessage: [*]const u8) callconv(.C) void,
    /// Returns a pointer to the error message contained in the map, or NULL if there is no error set. The pointer is valid until the next modifying operation on the map.
    mapGetError: ?*const fn (?*const Map) callconv(.C) ?[*]const u8,
    /// Returns the number of keys contained in a property map.
    mapNumKeys: ?*const fn (?*const Map) callconv(.C) c_int,
    /// Returns the nth key from a property map. Passing an invalid index will cause a fatal error. The pointer is valid as long as the key exists in the map.
    mapGetKey: ?*const fn (?*const Map, index: c_int) callconv(.C) [*]const u8,
    /// Removes the property with the given key. All values associated with the key are lost. Returns 0 if the key isn’t in the map. Otherwise it returns 1.
    mapDeleteKey: ?*const fn (?*Map, key: [*]const u8) callconv(.C) c_int,
    /// Returns the number of elements associated with a key in a property map. Returns -1 if there is no such key in the map.
    mapNumElements: ?*const fn (?*const Map, key: [*]const u8) callconv(.C) c_int,
    /// Returns a value from VSPropertyType representing type of elements in the given key. If there is no such key in the map, the returned value is ptUnset. Note that also empty arrays created with mapSetEmpty are typed.
    mapGetType: ?*const fn (?*const Map, key: [*]const u8) callconv(.C) PropertyType,
    /// Creates an empty array of type in key. Returns non-zero value on failure due to key already existing or having an invalid name.
    mapSetEmpty: ?*const fn (?*Map, key: [*]const u8, PropertyType) callconv(.C) c_int,
    /// Retrieves an integer from a specified key in a map. Returns the number on success, or 0 in case of error. If the map has an error set (i.e. if mapGetError() returns non-NULL), VapourSynth will die with a fatal error.
    mapGetInt: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) i64,
    /// Works just like mapGetInt() except that the value returned is also converted to an integer using saturation.
    mapGetIntSaturated: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) c_int,
    /// Retrieves an array of integers from a map. Use this function if there are a lot of numbers associated with a key, because it is faster than calling mapGetInt() in a loop.
    /// Returns a pointer to the first element of the array on success, or NULL in case of error. Use mapNumElements() to know the total number of elements associated with a key.
    mapGetIntArray: ?*const fn (?*const Map, key: [*]const u8, *MapPropertyError) callconv(.C) ?[*]const i64,
    /// Sets an integer to the specified key in a map. Multiple values can be associated with one key, but they must all be the same type.
    mapSetInt: ?*const fn (?*Map, key: [*]const u8, i64, MapAppendMode) callconv(.C) c_int,
    /// Adds an array of integers to a map. Use this function if there are a lot of numbers to add, because it is faster than calling mapSetInt() in a loop.
    /// If map already contains a property with this key, that property will be overwritten and all old values will be lost.
    mapSetIntArray: ?*const fn (?*Map, key: [*]const u8, arr: [*]const i64, size: c_int) callconv(.C) c_int,
    ///Retrieves a floating point number from a map. Returns the number on success, or 0 in case of error.
    mapGetFloat: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) f64,
    /// Works just like mapGetFloat() except that the value returned is also converted to a f32.
    mapGetFloatSaturated: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) f32,
    /// Retrieves an array of floating point numbers from a map. Use this function if there are a lot of numbers associated with a key, because it is faster than calling mapGetFloat() in a loop.
    /// Returns a pointer to the first element of the array on success, or NULL in case of error. Use mapNumElements() to know the total number of elements associated with a key.
    mapGetFloatArray: ?*const fn (?*const Map, key: [*]const u8, *MapPropertyError) callconv(.C) ?[*]const f64,
    /// Sets a float to the specified key in a map.
    mapSetFloat: ?*const fn (?*Map, key: [*]const u8, n: f64, MapAppendMode) callconv(.C) c_int,
    /// Adds an array of floating point numbers to a map. Use this function if there are a lot of numbers to add, because it is faster than calling mapSetFloat() in a loop.
    mapSetFloatArray: ?*const fn (?*Map, key: [*]const u8, arr: [*]const f64, size: c_int) callconv(.C) c_int,
    /// Retrieves arbitrary binary data from a map. Checking mapGetDataTypeHint() may provide a hint about whether or not the data is human readable.
    mapGetData: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) [*]const u8,
    /// Returns the size in bytes of a property of type ptData (see VSPropertyType), or 0 in case of error. The terminating NULL byte added by mapSetData() is not counted.
    mapGetDataSize: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) c_int,
    /// Returns the size in bytes of a property of type ptData (see VSPropertyType), or 0 in case of error. The terminating NULL byte added by mapSetData() is not counted.
    mapGetDataTypeHint: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) DataTypeHint,
    /// Sets binary data to the specified key in a map. Multiple values can be associated with one key, but they must all be the same type.
    mapSetData: ?*const fn (?*Map, key: [*]const u8, data: [*]const u8, size: c_int, DataTypeHint, MapAppendMode) callconv(.C) c_int,
    /// Retrieves a node from a map. Returns a pointer to the node on success, or NULL in case of error.
    /// This function increases the node’s reference count, so freeNode() must be used when the node is no longer needed.
    mapGetNode: ?*const fn (?*const Map, key: [*]const u8, index: c_int, ?*MapPropertyError) callconv(.C) ?*Node,
    /// Sets a node to the specified key in a map.
    mapSetNode: ?*const fn (?*Map, key: [*]const u8, ?*Node, MapAppendMode) callconv(.C) c_int,
    /// Sets a node to the specified key in a map and decreases the reference count.
    mapConsumeNode: ?*const fn (?*Map, key: [*]const u8, ?*Node, MapAppendMode) callconv(.C) c_int,
    /// Retrieves a frame from a map. Returns a pointer to the frame on success, or NULL in case of error.
    /// This function increases the frame’s reference count, so freeFrame() must be used when the frame is no longer needed.
    mapGetFrame: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) ?*const Frame,
    /// Sets a frame to the specified key in a map.
    mapSetFrame: ?*const fn (?*Map, key: [*]const u8, ?*const Frame, MapAppendMode) callconv(.C) c_int,
    /// Sets a frame to the specified key in a map and decreases the reference count.
    mapConsumeFrame: ?*const fn (?*Map, key: [*]const u8, ?*const Frame, MapAppendMode) callconv(.C) c_int,
    /// Retrieves a function from a map. Returns a pointer to the function on success, or NULL in case of error.
    /// This function increases the function’s reference count, so freeFunction() must be used when the function is no longer needed.
    mapGetFunction: ?*const fn (?*const Map, key: [*]const u8, index: c_int, *MapPropertyError) callconv(.C) ?*Function,
    /// Sets a function object to the specified key in a map.
    mapSetFunction: ?*const fn (?*Map, key: [*]const u8, ?*Function, MapAppendMode) callconv(.C) c_int,
    /// Sets a function object to the specified key in a map and decreases the reference count.
    mapConsumeFunction: ?*const fn (?*Map, key: [*]const u8, ?*Function, MapAppendMode) callconv(.C) c_int,
    /// Function that registers a filter exported by the plugin. A plugin can export any number of filters.
    /// This function may only be called during the plugin loading phase unless the pcModifiable flag was set by configPlugin.
    registerFunction: ?*const fn (name: [*]const u8, args: [*]const u8, returnType: [*]const u8, argsFunc: PublicFunction, functionData: ?*anyopaque, ?*Plugin) callconv(.C) c_int,
    /// Returns a pointer to the plugin with the given identifier, or NULL if not found.
    getPluginByID: ?*const fn (identifier: [*]const u8, ?*Core) callconv(.C) ?*Plugin,
    /// Returns a pointer to the plugin with the given namespace, or NULL if not found.
    getPluginByNamespace: ?*const fn (ns: [*]const u8, ?*Core) callconv(.C) ?*Plugin,
    /// Used to enumerate over all currently loaded plugins. The order is fixed but provides no other guarantees.
    getNextPlugin: ?*const fn (?*Plugin, ?*Core) callconv(.C) ?*Plugin,
    /// Returns the name of the plugin that was passed to configPlugin.
    getPluginName: ?*const fn (?*Plugin) callconv(.C) [*]const u8,
    /// Returns the identifier of the plugin that was passed to configPlugin.
    getPluginID: ?*const fn (?*Plugin) callconv(.C) [*]const u8,
    /// Returns the namespace the plugin currently is loaded in.
    getPluginNamespace: ?*const fn (?*Plugin) callconv(.C) [*]const u8,
    /// Used to enumerate over all functions in a plugin. The order is fixed but provides no other guarantees.
    getNextPluginFunction: ?*const fn (?*PluginFunction, ?*Plugin) callconv(.C) ?*PluginFunction,
    /// Get a function belonging to a plugin by its name.
    getPluginFunctionByName: ?*const fn (name: [*]const u8, ?*Plugin) callconv(.C) ?*PluginFunction,
    /// Returns the name of the function that was passed to registerFunction.
    getPluginFunctionName: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,
    /// Returns the argument string of the function that was passed to registerFunction.
    getPluginFunctionArguments: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,
    /// Returns the return type string of the function that was passed to registerFunction.
    getPluginFunctionReturnType: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,
    /// Returns the absolute path to the plugin, including the plugin’s file name. This is the real location of the plugin, i.e. there are no symbolic links in the path.
    getPluginPath: ?*const fn (?*const Plugin) callconv(.C) [*]const u8,
    /// Returns the version of the plugin. This is the same as the version number passed to configPlugin.
    getPluginVersion: ?*const fn (?*const Plugin) callconv(.C) c_int,
    /// Checks that the args passed to the filter are consistent with the argument list registered by the plugin that contains the filter, calls the filter’s
    /// “create” function, and checks that the filter returns the declared types. If everything goes smoothly, the filter will be ready to generate frames after invoke() returns.
    invoke: ?*const fn (?*Plugin, [*]const u8, ?*const Map) callconv(.C) ?*Map,
    /// Creates the VapourSynth processing core and returns a pointer to it. It is possible to create multiple cores but in most cases it shouldn’t be needed.
    createCore: ?*const fn (CoreCreationFlags) callconv(.C) ?*Core,
    /// Frees a core. Should only be done after all frame requests have completed and all objects belonging to the core have been released.
    freeCore: ?*const fn (?*Core) callconv(.C) void,
    /// Sets the maximum size of the framebuffer cache. Returns the new maximum size.
    setMaxCacheSize: ?*const fn (bytes: i64, ?*Core) callconv(.C) i64,
    /// Sets the number of threads used for processing. Pass 0 to automatically detect. Returns the number of threads that will be used for processing.
    setThreadCount: ?*const fn (threads: c_int, ?*Core) callconv(.C) c_int,
    /// Returns information about the VapourSynth core.
    getCoreInfo: ?*const fn (?*Core, *CoreInfo) callconv(.C) void,
    /// Returns the highest VAPOURSYNTH_API_VERSION the library support.
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    /// Send a message through VapourSynth’s logging framework. See addLogHandler.
    logMessage: ?*const fn (MessageType, msg: [*]const u8, ?*Core) callconv(.C) void,
    /// Installs a custom handler for the various error messages VapourSynth emits. The message handler is per VSCore instance. Returns a unique handle.
    addLogHandler: ?*const fn (LogHandler, LogHandlerFree, userData: ?*anyopaque, ?*Core) callconv(.C) ?*LogHandle,
    /// Removes a custom handler. Return non-zero on success and zero if the handle is invalid.
    removeLogHandler: ?*const fn (?*LogHandle, ?*Core) callconv(.C) c_int,
};

pub extern fn getVapourSynthAPI(version: c_int) *const API;
