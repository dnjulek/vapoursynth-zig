//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VapourSynth4.h

pub inline fn makeVersion(major: c_int, minor: c_int) c_int {
    return (major << @as(c_int, 16)) | minor;
}

pub const VAPOURSYNTH_API_MAJOR: c_int = 4;
pub const VAPOURSYNTH_API_MINOR: c_int = 0;
pub const VAPOURSYNTH_API_VERSION: c_int = makeVersion(VAPOURSYNTH_API_MAJOR, VAPOURSYNTH_API_MINOR);
pub const AUDIO_FRAME_SAMPLES: c_int = 3072;

pub const Frame = opaque {};
pub const Node = opaque {};
pub const Core = opaque {};
pub const Plugin = opaque {};
pub const PluginFunction = opaque {};
pub const Function = opaque {};
pub const Map = opaque {};
pub const LogHandle = opaque {};
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

pub const PresetVideoFormat = enum(c_int) {
    None = 0,

    Gray8 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 8, 0, 0),
    Gray9 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 9, 0, 0),
    Gray10 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 10, 0, 0),
    Gray12 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 12, 0, 0),
    Gray14 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 14, 0, 0),
    Gray16 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 16, 0, 0),
    Gray32 = makeVideoID(ColorFamily.Gray, SampleType.Integer, 32, 0, 0),

    GrayH = makeVideoID(ColorFamily.Gray, SampleType.Float, 16, 0, 0),
    GrayS = makeVideoID(ColorFamily.Gray, SampleType.Float, 32, 0, 0),

    YUV410P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 2, 2),
    YUV411P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 2, 0),
    YUV440P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 0, 1),

    YUV420P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 1, 1),
    YUV422P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 1, 0),
    YUV444P8 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 8, 0, 0),

    YUV420P9 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 9, 1, 1),
    YUV422P9 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 9, 1, 0),
    YUV444P9 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 9, 0, 0),

    YUV420P10 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 10, 1, 1),
    YUV422P10 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 10, 1, 0),
    YUV444P10 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 10, 0, 0),

    YUV420P12 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 12, 1, 1),
    YUV422P12 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 12, 1, 0),
    YUV444P12 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 12, 0, 0),

    YUV420P14 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 14, 1, 1),
    YUV422P14 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 14, 1, 0),
    YUV444P14 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 14, 0, 0),

    YUV420P16 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 16, 1, 1),
    YUV422P16 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 16, 1, 0),
    YUV444P16 = makeVideoID(ColorFamily.YUV, SampleType.Integer, 16, 0, 0),

    YUV444PH = makeVideoID(ColorFamily.YUV, SampleType.Float, 16, 0, 0),
    YUV444PS = makeVideoID(ColorFamily.YUV, SampleType.Float, 32, 0, 0),

    RGB24 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 8, 0, 0),
    RGB27 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 9, 0, 0),
    RGB30 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 10, 0, 0),
    RGB36 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 12, 0, 0),
    RGB42 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 14, 0, 0),
    RGB48 = makeVideoID(ColorFamily.RGB, SampleType.Integer, 16, 0, 0),

    RGBH = makeVideoID(ColorFamily.RGB, SampleType.Float, 16, 0, 0),
    RGBS = makeVideoID(ColorFamily.RGB, SampleType.Float, 32, 0, 0),
};

pub const FilterMode = enum(c_int) {
    /// completely parallel execution
    Parallel = 0,

    /// for filters that are serial in nature but can request one or more frames they need in advance
    ParallelRequests = 1,

    /// for filters that modify their internal state every request like source filters that read a file
    Unordered = 2,

    /// DO NOT USE UNLESS ABSOLUTELY NECESSARY, for compatibility with external code that can only keep the processing state of a single frame at a time
    FrameState = 3,
};

pub const MediaType = enum(c_int) {
    Video = 1,
    Audio = 2,
};

pub const VideoFormat = extern struct {
    colorFamily: ColorFamily,

    sampleType: SampleType,

    /// number of significant bits
    bitsPerSample: c_int,

    /// actual storage is always in a power of 2 and the smallest possible that can fit the number of bits used per sample
    bytesPerSample: c_int,

    /// log2 subsampling factor, applied to second and third plane
    subSamplingW: c_int,

    /// log2 subsampling factor, applied to second and third plane
    subSamplingH: c_int,

    /// implicit from colorFamily
    numPlanes: c_int,
};

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

pub const AudioFormat = extern struct {
    sampleType: c_int,

    bitsPerSample: c_int,

    /// implicit from bitsPerSample
    bytesPerSample: c_int,

    /// implicit from channelLayout
    numChannels: c_int,

    channelLayout: u64,
};

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

pub const MapAppendMode = enum(c_int) {
    Replace = 0,
    Append = 1,
};

pub const CoreInfo = extern struct {
    versionString: [*]const u8,
    core: c_int,
    api: c_int,
    numThreads: c_int,
    maxFramebufferSize: i64,
    usedFramebufferSize: i64,
};

pub const VideoInfo = extern struct {
    format: VideoFormat,
    fpsNum: i64,
    fpsDen: i64,
    width: c_int,
    height: c_int,
    numFrames: c_int,
};

pub const AudioInfo = extern struct {
    format: AudioFormat,

    sampleRate: c_int,

    numSamples: i64,

    /// the total number of audio frames needed to hold numSamples, implicit from numSamples when calling createAudioFilter
    numFrames: c_int,
};

pub const ActivationReason = enum(c_int) {
    Initial = 0,
    AllFramesReady = 1,
    Error = -1,
};

pub const MessageType = enum(c_int) {
    Debug = 0,

    Information = 1,

    Warning = 2,

    Critical = 3,

    /// also terminates the process, should generally not be used by normal filters
    Fatal = 4,
};

pub const CoreCreationFlags = enum(c_int) {
    EnableGraphInspection = 1,
    DisableAutoLoading = 2,
    DisableLibraryUnloading = 4,
};

pub const PluginConfigFlags = enum(c_int) {
    Modifiable = 1,
};

pub const DataTypeHint = enum(c_int) {
    Unknown = -1,
    Binary = 0,
    Utf8 = 1,
};

pub const RequestPattern = enum(c_int) {
    /// General pattern
    General = 0,

    /// When requesting all output frames from the filter no frame will be requested more than once from this input clip, never requests frames beyond the end of the clip
    NoFrameReuse = 1,

    /// Always (and only) requests frame n from input clip when generating output frame n, never requests frames beyond the end of the clip
    StrictSpatial = 2,
};

pub const CacheMode = enum(c_int) {
    Auto = -1,
    ForceDisable = 0,
    ForceEnable = 1,
};

// Core entry point
pub const GetVapourSynthAPI = ?*const fn (c_int) callconv(.C) *const API;

// Plugin, function and filter related
pub const PublicFunction = ?*const fn (?*const Map, ?*Map, ?*anyopaque, ?*Core, *const API) callconv(.C) void;
pub const InitPlugin = ?*const fn (?*Plugin, *const PLUGINAPI) callconv(.C) void;
pub const FreeFunctionData = ?*const fn (?*anyopaque) callconv(.C) void;
pub const FilterGetFrame = ?*const fn (c_int, ActivationReason, ?*anyopaque, *?*anyopaque, ?*FrameContext, ?*Core, *const API) callconv(.C) ?*const Frame;
pub const FilterFree = ?*const fn (?*anyopaque, ?*Core, *const API) callconv(.C) void;

// Other
pub const FrameDoneCallback = ?*const fn (?*anyopaque, ?*const Frame, c_int, ?*Node, [*]const u8) callconv(.C) void;
pub const LogHandler = ?*const fn (MessageType, [*]const u8, ?*anyopaque) callconv(.C) void;
pub const LogHandlerFree = ?*const fn (?*anyopaque) callconv(.C) void;

pub const PLUGINAPI = extern struct {
    /// returns VAPOURSYNTH_API_VERSION of the library
    getAPIVersion: ?*const fn () callconv(.C) c_int,

    /// use the VS_MAKE_VERSION macro for pluginVersion
    ///
    /// (identifier, pluginNamespace, name, pluginVersion, apiVersion, flags, plugin)
    configPlugin: ?*const fn ([*]const u8, [*]const u8, [*]const u8, c_int, c_int, c_int, ?*Plugin) callconv(.C) c_int,

    /// non-zero return value on success
    ///
    /// (name, args, returnType, argsFunc, functionData, plugin)
    registerFunction: ?*const fn ([*]const u8, [*]const u8, [*]const u8, PublicFunction, ?*anyopaque, ?*Plugin) callconv(.C) c_int,
};

pub const FilterDependency = extern struct {
    source: ?*Node,
    requestPattern: RequestPattern,
};

pub const API = extern struct {
    /// output nodes are appended to the clip key in the out map
    ///
    /// (out, name, vi, getFrame, free, filterMode, dependencies, numDeps, instanceData, core)
    createVideoFilter: ?*const fn (?*Map, [*]const u8, *const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) void,

    /// same as createVideoFilter but returns a pointer to the VSNode directly or NULL on failure
    ///
    /// (name, vi, getFrame, free, filterMode, dependencies, numDeps, instanceData, core)
    createVideoFilter2: ?*const fn ([*]const u8, *const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) ?*Node,

    /// output nodes are appended to the clip key in the out map
    ///
    /// (out, name, ai, getFrame, free, filterMode, dependencies, numDeps, instanceData, core)
    createAudioFilter: ?*const fn (?*Map, [*]const u8, *const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) void,

    /// same as createAudioFilter but returns a pointer to the VSNode directly or NULL on failure
    ///
    /// (name, ai, getFrame, free, filterMode, dependencies, numDeps, instanceData, core)
    createAudioFilter2: ?*const fn ([*]const u8, *const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) ?*Node,

    /// Use right after create*Filter*, sets the correct cache mode for using the cacheFrame API and returns the recommended upper number of additional frames to cache per request
    setLinearFilter: ?*const fn (?*Node) callconv(.C) c_int,

    /// VSCacheMode, changing the cache mode also resets all options to their default
    setCacheMode: ?*const fn (?*Node, CacheMode) callconv(.C) void,

    /// passing -1 means no change
    ///
    /// (node, fixedSize, maxSize, maxHistorySize)
    setCacheOptions: ?*const fn (?*Node, c_int, c_int, c_int) callconv(.C) void,

    freeNode: ?*const fn (?*Node) callconv(.C) void,
    addNodeRef: ?*const fn (?*Node) callconv(.C) ?*Node,
    getNodeType: ?*const fn (?*Node) callconv(.C) MediaType,
    getVideoInfo: ?*const fn (?*Node) callconv(.C) *const VideoInfo,
    getAudioInfo: ?*const fn (?*Node) callconv(.C) *const AudioInfo,

    /// (format, width, height, propSrc, core)
    newVideoFrame: ?*const fn (*const VideoFormat, c_int, c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,

    /// same as newVideoFrame but allows the specified planes to be effectively copied from the source frames
    ///
    /// (format, width, height, planeSrc, planes, propSrc, core)
    newVideoFrame2: ?*const fn (*const VideoFormat, c_int, c_int, *?*const Frame, *const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,

    /// (format, numSamples, propSrc, core)
    newAudioFrame: ?*const fn (*const AudioFormat, c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,

    /// same as newAudioFrame but allows the specified channels to be effectively copied from the source frames
    ///
    /// (format, numSamples, channelSrc, channels, propSrc, core)
    newAudioFrame2: ?*const fn (*const AudioFormat, c_int, *?*const Frame, *const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,

    freeFrame: ?*const fn (?*const Frame) callconv(.C) void,
    addFrameRef: ?*const fn (?*const Frame) callconv(.C) ?*const Frame,
    copyFrame: ?*const fn (?*const Frame, ?*Core) callconv(.C) ?*Frame,
    getFramePropertiesRO: ?*const fn (?*const Frame) callconv(.C) ?*const Map,
    getFramePropertiesRW: ?*const fn (?*Frame) callconv(.C) ?*Map,

    /// (f, plane)
    getStride: ?*const fn (?*const Frame, c_int) callconv(.C) c_longlong,

    /// (f, plane)
    getReadPtr: ?*const fn (?*const Frame, c_int) callconv(.C) [*]const u8,

    ///calling this function invalidates previously gotten read pointers to the same frame
    ///
    /// (f, plane)
    getWritePtr: ?*const fn (?*Frame, c_int) callconv(.C) [*]u8,
    getVideoFrameFormat: ?*const fn (?*const Frame) callconv(.C) *const VideoFormat,
    getAudioFrameFormat: ?*const fn (?*const Frame) callconv(.C) *const AudioFormat,
    getFrameType: ?*const fn (?*const Frame) callconv(.C) MediaType,

    /// (f, plane)
    getFrameWidth: ?*const fn (?*const Frame, c_int) callconv(.C) c_int,

    /// (f, plane)
    getFrameHeight: ?*const fn (?*const Frame, c_int) callconv(.C) c_int,

    /// returns the number of samples for audio frames
    getFrameLength: ?*const fn (?*const Frame) callconv(.C) c_int,

    /// up to 32 characters including terminating null may be written to the buffer, non-zero return value on success
    getVideoFormatName: ?*const fn (*const VideoFormat, [*]u8) callconv(.C) c_int,

    /// up to 32 characters including terminating null may be written to the buffer, non-zero return value on success
    getAudioFormatName: ?*const fn (*const AudioFormat, [*]u8) callconv(.C) c_int,

    /// non-zero return value on success
    ///
    /// (format, colorFamily, sampleType, bitsPerSample, subSamplingW, subSamplingH, core)
    queryVideoFormat: ?*const fn (*VideoFormat, ColorFamily, SampleType, c_int, c_int, c_int, ?*Core) callconv(.C) c_int,

    /// non-zero return value on success
    ///
    /// (format, sampleType, bitsPerSample, channelLayout, core)
    queryAudioFormat: ?*const fn (*AudioFormat, SampleType, c_int, u64, ?*Core) callconv(.C) c_int,

    /// returns 0 on failure
    ///
    /// (colorFamily, sampleType, bitsPerSample, subSamplingW, subSamplingH, core)
    queryVideoFormatID: ?*const fn (ColorFamily, SampleType, c_int, c_int, c_int, ?*Core) callconv(.C) u32,

    /// non-zero return value on success
    ///
    /// (format, id, core)
    getVideoFormatByID: ?*const fn (*VideoFormat, u32, ?*Core) callconv(.C) c_int,

    /// only for external applications using the core as a library or for requesting frames in a filter constructor, do not use inside a filter's getframe function
    ///
    /// (n, node, errorMsg, bufSize)
    getFrame: ?*const fn (c_int, ?*Node, [*]u8, c_int) callconv(.C) ?*const Frame,

    /// only for external applications using the core as a library or for requesting frames in a filter constructor, do not use inside a filter's getframe function
    getFrameAsync: ?*const fn (c_int, ?*Node, FrameDoneCallback, ?*anyopaque) callconv(.C) void,

    /// only use inside a filter's getframe function
    getFrameFilter: ?*const fn (c_int, ?*Node, ?*FrameContext) callconv(.C) ?*const Frame,

    /// only use inside a filter's getframe function
    requestFrameFilter: ?*const fn (c_int, ?*Node, ?*FrameContext) callconv(.C) void,

    /// only use inside a filter's getframe function
    releaseFrameEarly: ?*const fn (?*Node, c_int, ?*FrameContext) callconv(.C) void,

    /// used to store intermediate frames in cache, useful for filters where random access is slow, must call setLinearFilter on the node before using or the result is undefined
    cacheFrame: ?*const fn (?*const Frame, c_int, ?*FrameContext) callconv(.C) void,

    /// used to signal errors in the filter getframe function
    setFilterError: ?*const fn ([*]const u8, ?*FrameContext) callconv(.C) void,

    // External functions
    createFunction: ?*const fn (PublicFunction, ?*anyopaque, FreeFunctionData, ?*Core) callconv(.C) ?*Function,
    freeFunction: ?*const fn (?*Function) callconv(.C) void,
    addFunctionRef: ?*const fn (?*Function) callconv(.C) ?*Function,
    callFunction: ?*const fn (?*Function, ?*const Map, ?*Map) callconv(.C) void,

    // Map and property access functions
    createMap: ?*const fn () callconv(.C) ?*Map,
    freeMap: ?*const fn (?*Map) callconv(.C) void,
    clearMap: ?*const fn (?*Map) callconv(.C) void,

    /// copies all values in src to dst, if a key already exists in dst it's replaced
    copyMap: ?*const fn (?*const Map, ?*Map) callconv(.C) void,

    /// used to signal errors outside filter getframe function
    mapSetError: ?*const fn (?*Map, [*]const u8) callconv(.C) void,

    /// used to query errors, returns 0 if no error
    mapGetError: ?*const fn (?*const Map) callconv(.C) [*]const u8,

    mapNumKeys: ?*const fn (?*const Map) callconv(.C) c_int,

    /// (map, index)
    mapGetKey: ?*const fn (?*const Map, c_int) callconv(.C) [*]const u8,
    mapDeleteKey: ?*const fn (?*Map, [*]const u8) callconv(.C) c_int,

    /// returns -1 if a key doesn't exist
    mapNumElements: ?*const fn (?*const Map, [*]const u8) callconv(.C) c_int,
    mapGetType: ?*const fn (?*const Map, [*]const u8) callconv(.C) PropertyType,

    /// (map, key, type)
    mapSetEmpty: ?*const fn (?*Map, [*]const u8, c_int) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetInt: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) i64,

    /// (map, key, index, error)
    mapGetIntSaturated: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) c_int,

    /// (map, key, error)
    mapGetIntArray: ?*const fn (?*const Map, [*]const u8, *c_int) callconv(.C) [*]const i64,

    /// (map, key, i, append)
    mapSetInt: ?*const fn (?*Map, [*]const u8, i64, MapAppendMode) callconv(.C) c_int,

    /// (map, key, i, size)
    mapSetIntArray: ?*const fn (?*Map, [*]const u8, [*]const i64, c_int) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetFloat: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) f64,

    /// (map, key, index, error)
    mapGetFloatSaturated: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) f32,

    /// (map, key, error)
    mapGetFloatArray: ?*const fn (?*const Map, [*]const u8, *c_int) callconv(.C) [*]const f64,

    /// (map, key, i, append)
    mapSetFloat: ?*const fn (?*Map, [*]const u8, f64, MapAppendMode) callconv(.C) c_int,

    /// (map, key, i, size)
    mapSetFloatArray: ?*const fn (?*Map, [*]const u8, [*]const f64, c_int) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetData: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) [*]const u8,

    /// (map, key, index, error)
    mapGetDataSize: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetDataTypeHint: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) DataTypeHint,

    /// (map, key, data, size, type, append)
    mapSetData: ?*const fn (?*Map, [*]const u8, [*]const u8, c_int, DataTypeHint, MapAppendMode) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetNode: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) ?*Node,

    /// returns 0 on success
    /// (map, key, node, append)
    mapSetNode: ?*const fn (?*Map, [*]const u8, ?*Node, MapAppendMode) callconv(.C) c_int,

    /// always consumes the reference, even on error
    ///
    /// (map, key, node, append)
    mapConsumeNode: ?*const fn (?*Map, [*]const u8, ?*Node, MapAppendMode) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetFrame: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) ?*const Frame,

    /// returns 0 on success
    ///
    /// (map, key, f, append)
    mapSetFrame: ?*const fn (?*Map, [*]const u8, ?*const Frame, MapAppendMode) callconv(.C) c_int,

    /// always consumes the reference, even on error
    ///
    /// (map, key, f, append)
    mapConsumeFrame: ?*const fn (?*Map, [*]const u8, ?*const Frame, MapAppendMode) callconv(.C) c_int,

    /// (map, key, index, error)
    mapGetFunction: ?*const fn (?*const Map, [*]const u8, c_int, *c_int) callconv(.C) ?*Function,

    /// returns 0 on success
    ///
    /// (map, key, func, append)
    mapSetFunction: ?*const fn (?*Map, [*]const u8, ?*Function, MapAppendMode) callconv(.C) c_int,

    /// always consumes the reference, even on error
    ///
    /// (map, key, func, append)
    mapConsumeFunction: ?*const fn (?*Map, [*]const u8, ?*Function, MapAppendMode) callconv(.C) c_int,

    /// non-zero return value on success
    ///
    /// (name, args, returnType, argsFunc, functionData, plugin)
    registerFunction: ?*const fn ([*]const u8, [*]const u8, [*]const u8, PublicFunction, ?*anyopaque, ?*Plugin) callconv(.C) c_int,
    getPluginByID: ?*const fn ([*]const u8, ?*Core) callconv(.C) ?*Plugin,
    getPluginByNamespace: ?*const fn ([*]const u8, ?*Core) callconv(.C) ?*Plugin,

    /// pass NULL to get the first plugin
    getNextPlugin: ?*const fn (?*Plugin, ?*Core) callconv(.C) ?*Plugin,
    getPluginName: ?*const fn (?*Plugin) callconv(.C) [*]const u8,
    getPluginID: ?*const fn (?*Plugin) callconv(.C) [*]const u8,
    getPluginNamespace: ?*const fn (?*Plugin) callconv(.C) [*]const u8,

    /// pass NULL to get the first plugin function
    getNextPluginFunction: ?*const fn (?*PluginFunction, ?*Plugin) callconv(.C) ?*PluginFunction,
    getPluginFunctionByName: ?*const fn ([*]const u8, ?*Plugin) callconv(.C) ?*PluginFunction,
    getPluginFunctionName: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,

    /// returns an argument format string
    getPluginFunctionArguments: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,

    /// returns an argument format string
    getPluginFunctionReturnType: ?*const fn (?*PluginFunction) callconv(.C) [*]const u8,

    /// the full path to the loaded library file containing the plugin entry point
    getPluginPath: ?*const fn (?*const Plugin) callconv(.C) [*]const u8,
    getPluginVersion: ?*const fn (?*const Plugin) callconv(.C) c_int,

    /// user must free the returned VSMap
    invoke: ?*const fn (?*Plugin, [*]const u8, ?*const Map) callconv(.C) ?*Map,
    createCore: ?*const fn (CoreCreationFlags) callconv(.C) ?*Core,

    /// only call this function after all node, frame and function references belonging to the core have been freed
    freeCore: ?*const fn (?*Core) callconv(.C) void,

    /// the total cache size (in bytes) at which vapoursynth more aggressively tries to reclaim memory, it is not a hard limit
    setMaxCacheSize: ?*const fn (i64, ?*Core) callconv(.C) i64,

    /// setting threads to 0 means automatic detection
    setThreadCount: ?*const fn (c_int, ?*Core) callconv(.C) c_int,
    getCoreInfo: ?*const fn (?*Core, *CoreInfo) callconv(.C) void,
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    logMessage: ?*const fn (MessageType, [*]const u8, ?*Core) callconv(.C) void,

    /// free and userData can be NULL, returns a handle that can be passed to removeLogHandler
    addLogHandler: ?*const fn (LogHandler, LogHandlerFree, ?*anyopaque, ?*Core) callconv(.C) ?*LogHandle,

    /// returns non-zero if successfully removed
    removeLogHandler: ?*const fn (?*LogHandle, ?*Core) callconv(.C) c_int,
};

pub extern fn getVapourSynthAPI(version: c_int) *const API;
