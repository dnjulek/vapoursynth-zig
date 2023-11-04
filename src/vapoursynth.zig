// https://github.com/vapoursynth/vapoursynth/blob/master/include/VapourSynth4.h

pub inline fn make_version(major: c_int, minor: c_int) c_int {
    return (major << @as(c_int, 16)) | minor;
}

pub const VAPOURSYNTH_API_MAJOR: c_int = 4;
pub const VAPOURSYNTH_API_MINOR: c_int = 0;
pub const VAPOURSYNTH_API_VERSION: c_int = make_version(VAPOURSYNTH_API_MAJOR, VAPOURSYNTH_API_MINOR);
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

pub inline fn make_video_id(colorFamily: ColorFamily, sampleType: SampleType, bitsPerSample: c_int, subSamplingW: c_int, subSamplingH: c_int) PresetVideoFormat {
    return ((colorFamily << 28) | (sampleType << 24) | (bitsPerSample << 16) | (subSamplingW << 8) | (subSamplingH << 0));
}

pub const PresetVideoFormat = enum(c_int) {
    None = 0,

    Gray8 = make_video_id(ColorFamily.Gray, SampleType.Integer, 8, 0, 0),
    Gray9 = make_video_id(ColorFamily.Gray, SampleType.Integer, 9, 0, 0),
    Gray10 = make_video_id(ColorFamily.Gray, SampleType.Integer, 10, 0, 0),
    Gray12 = make_video_id(ColorFamily.Gray, SampleType.Integer, 12, 0, 0),
    Gray14 = make_video_id(ColorFamily.Gray, SampleType.Integer, 14, 0, 0),
    Gray16 = make_video_id(ColorFamily.Gray, SampleType.Integer, 16, 0, 0),
    Gray32 = make_video_id(ColorFamily.Gray, SampleType.Integer, 32, 0, 0),

    GrayH = make_video_id(ColorFamily.Gray, SampleType.Float, 16, 0, 0),
    GrayS = make_video_id(ColorFamily.Gray, SampleType.Float, 32, 0, 0),

    YUV410P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 2, 2),
    YUV411P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 2, 0),
    YUV440P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 0, 1),

    YUV420P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 1, 1),
    YUV422P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 1, 0),
    YUV444P8 = make_video_id(ColorFamily.YUV, SampleType.Integer, 8, 0, 0),

    YUV420P9 = make_video_id(ColorFamily.YUV, SampleType.Integer, 9, 1, 1),
    YUV422P9 = make_video_id(ColorFamily.YUV, SampleType.Integer, 9, 1, 0),
    YUV444P9 = make_video_id(ColorFamily.YUV, SampleType.Integer, 9, 0, 0),

    YUV420P10 = make_video_id(ColorFamily.YUV, SampleType.Integer, 10, 1, 1),
    YUV422P10 = make_video_id(ColorFamily.YUV, SampleType.Integer, 10, 1, 0),
    YUV444P10 = make_video_id(ColorFamily.YUV, SampleType.Integer, 10, 0, 0),

    YUV420P12 = make_video_id(ColorFamily.YUV, SampleType.Integer, 12, 1, 1),
    YUV422P12 = make_video_id(ColorFamily.YUV, SampleType.Integer, 12, 1, 0),
    YUV444P12 = make_video_id(ColorFamily.YUV, SampleType.Integer, 12, 0, 0),

    YUV420P14 = make_video_id(ColorFamily.YUV, SampleType.Integer, 14, 1, 1),
    YUV422P14 = make_video_id(ColorFamily.YUV, SampleType.Integer, 14, 1, 0),
    YUV444P14 = make_video_id(ColorFamily.YUV, SampleType.Integer, 14, 0, 0),

    YUV420P16 = make_video_id(ColorFamily.YUV, SampleType.Integer, 16, 1, 1),
    YUV422P16 = make_video_id(ColorFamily.YUV, SampleType.Integer, 16, 1, 0),
    YUV444P16 = make_video_id(ColorFamily.YUV, SampleType.Integer, 16, 0, 0),

    YUV444PH = make_video_id(ColorFamily.YUV, SampleType.Float, 16, 0, 0),
    YUV444PS = make_video_id(ColorFamily.YUV, SampleType.Float, 32, 0, 0),

    RGB24 = make_video_id(ColorFamily.RGB, SampleType.Integer, 8, 0, 0),
    RGB27 = make_video_id(ColorFamily.RGB, SampleType.Integer, 9, 0, 0),
    RGB30 = make_video_id(ColorFamily.RGB, SampleType.Integer, 10, 0, 0),
    RGB36 = make_video_id(ColorFamily.RGB, SampleType.Integer, 12, 0, 0),
    RGB42 = make_video_id(ColorFamily.RGB, SampleType.Integer, 14, 0, 0),
    RGB48 = make_video_id(ColorFamily.RGB, SampleType.Integer, 16, 0, 0),

    RGBH = make_video_id(ColorFamily.RGB, SampleType.Float, 16, 0, 0),
    RGBS = make_video_id(ColorFamily.RGB, SampleType.Float, 32, 0, 0),
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
    acFrontLeft = 0,
    acFrontRight = 1,
    acFrontCenter = 2,
    acLowFrequency = 3,
    acBackLeft = 4,
    acBackRight = 5,
    acFrontLeftOFCenter = 6,
    acFrontRightOFCenter = 7,
    acBackCenter = 8,
    acSideLeft = 9,
    acSideRight = 10,
    acTopCenter = 11,
    acTopFrontLeft = 12,
    acTopFrontCenter = 13,
    acTopFrontRight = 14,
    acTopBackLeft = 15,
    acTopBackCenter = 16,
    acTopBackRight = 17,
    acStereoLeft = 29,
    acStereoRight = 30,
    acWideLeft = 31,
    acWideRight = 32,
    acSurroundDirectLeft = 33,
    acSurroundDirectRight = 34,
    acLowFrequency2 = 35,
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
    peSuccess = 0,

    /// no key exists
    peUnset = 1,

    /// key exists but not of a compatible type
    peType = 2,

    /// index out of bounds
    peIndex = 4,

    /// map has error state set
    peError = 3,
};

pub const MapAppendMode = enum(c_int) {
    maReplace = 0,
    maAppend = 1,
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
pub const GetVapourSynthAPI = ?*const fn (c_int) callconv(.C) [*c]const API;

// Plugin, function and filter related
pub const PublicFunction = ?*const fn (?*const Map, ?*Map, ?*anyopaque, ?*Core, [*c]const API) callconv(.C) void;
pub const InitPlugin = ?*const fn (?*Plugin, [*c]const PLUGINAPI) callconv(.C) void;
pub const FreeFunctionData = ?*const fn (?*anyopaque) callconv(.C) void;
pub const FilterGetFrame = ?*const fn (c_int, ActivationReason, ?*anyopaque, [*c]?*anyopaque, ?*FrameContext, ?*Core, [*c]const API) callconv(.C) ?*const Frame;
pub const FilterFree = ?*const fn (?*anyopaque, ?*Core, [*c]const API) callconv(.C) void;

// Other
pub const FrameDoneCallback = ?*const fn (?*anyopaque, ?*const Frame, c_int, ?*Node, [*c]const u8) callconv(.C) void;
pub const LogHandler = ?*const fn (c_int, [*c]const u8, ?*anyopaque) callconv(.C) void;
pub const LogHandlerFree = ?*const fn (?*anyopaque) callconv(.C) void;

pub const PLUGINAPI = extern struct {
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    configPlugin: ?*const fn ([*c]const u8, [*c]const u8, [*c]const u8, c_int, c_int, c_int, ?*Plugin) callconv(.C) c_int,
    registerFunction: ?*const fn ([*c]const u8, [*c]const u8, [*c]const u8, PublicFunction, ?*anyopaque, ?*Plugin) callconv(.C) c_int,
};

pub const FilterDependency = extern struct {
    source: ?*Node,
    requestPattern: RequestPattern,
};

pub const API = extern struct {
    createVideoFilter: ?*const fn (?*Map, [*c]const u8, [*c]const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*c]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) void,
    createVideoFilter2: ?*const fn ([*c]const u8, [*c]const VideoInfo, FilterGetFrame, FilterFree, FilterMode, [*c]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) ?*Node,
    createAudioFilter: ?*const fn (?*Map, [*c]const u8, [*c]const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*c]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) void,
    createAudioFilter2: ?*const fn ([*c]const u8, [*c]const AudioInfo, FilterGetFrame, FilterFree, FilterMode, [*c]const FilterDependency, c_int, ?*anyopaque, ?*Core) callconv(.C) ?*Node,
    setLinearFilter: ?*const fn (?*Node) callconv(.C) c_int,
    setCacheMode: ?*const fn (?*Node, c_int) callconv(.C) void,
    setCacheOptions: ?*const fn (?*Node, c_int, c_int, c_int) callconv(.C) void,
    freeNode: ?*const fn (?*Node) callconv(.C) void,
    addNodeRef: ?*const fn (?*Node) callconv(.C) ?*Node,
    getNodeType: ?*const fn (?*Node) callconv(.C) c_int,
    getVideoInfo: ?*const fn (?*Node) callconv(.C) [*c]const VideoInfo,
    getAudioInfo: ?*const fn (?*Node) callconv(.C) [*c]const AudioInfo,
    newVideoFrame: ?*const fn ([*c]const VideoFormat, c_int, c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    newVideoFrame2: ?*const fn ([*c]const VideoFormat, c_int, c_int, [*c]?*const Frame, [*c]const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    newAudioFrame: ?*const fn ([*c]const AudioFormat, c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    newAudioFrame2: ?*const fn ([*c]const AudioFormat, c_int, [*c]?*const Frame, [*c]const c_int, ?*const Frame, ?*Core) callconv(.C) ?*Frame,
    freeFrame: ?*const fn (?*const Frame) callconv(.C) void,
    addFrameRef: ?*const fn (?*const Frame) callconv(.C) ?*const Frame,
    copyFrame: ?*const fn (?*const Frame, ?*Core) callconv(.C) ?*Frame,
    getFramePropertiesRO: ?*const fn (?*const Frame) callconv(.C) ?*const Map,
    getFramePropertiesRW: ?*const fn (?*Frame) callconv(.C) ?*Map,
    getStride: ?*const fn (?*const Frame, c_int) callconv(.C) c_longlong,
    getReadPtr: ?*const fn (?*const Frame, c_int) callconv(.C) [*c]const u8,
    getWritePtr: ?*const fn (?*Frame, c_int) callconv(.C) [*c]u8,
    getVideoFrameFormat: ?*const fn (?*const Frame) callconv(.C) [*c]const VideoFormat,
    getAudioFrameFormat: ?*const fn (?*const Frame) callconv(.C) [*c]const AudioFormat,
    getFrameType: ?*const fn (?*const Frame) callconv(.C) c_int,
    getFrameWidth: ?*const fn (?*const Frame, c_int) callconv(.C) c_int,
    getFrameHeight: ?*const fn (?*const Frame, c_int) callconv(.C) c_int,
    getFrameLength: ?*const fn (?*const Frame) callconv(.C) c_int,
    getVideoFormatName: ?*const fn ([*c]const VideoFormat, [*c]u8) callconv(.C) c_int,
    getAudioFormatName: ?*const fn ([*c]const AudioFormat, [*c]u8) callconv(.C) c_int,
    queryVideoFormat: ?*const fn ([*c]VideoFormat, c_int, c_int, c_int, c_int, c_int, ?*Core) callconv(.C) c_int,
    queryAudioFormat: ?*const fn ([*c]AudioFormat, c_int, c_int, u64, ?*Core) callconv(.C) c_int,
    queryVideoFormatID: ?*const fn (c_int, c_int, c_int, c_int, c_int, ?*Core) callconv(.C) u32,
    getVideoFormatByID: ?*const fn ([*c]VideoFormat, u32, ?*Core) callconv(.C) c_int,
    getFrame: ?*const fn (c_int, ?*Node, [*c]u8, c_int) callconv(.C) ?*const Frame,
    getFrameAsync: ?*const fn (c_int, ?*Node, FrameDoneCallback, ?*anyopaque) callconv(.C) void,
    getFrameFilter: ?*const fn (c_int, ?*Node, ?*FrameContext) callconv(.C) ?*const Frame,
    requestFrameFilter: ?*const fn (c_int, ?*Node, ?*FrameContext) callconv(.C) void,
    releaseFrameEarly: ?*const fn (?*Node, c_int, ?*FrameContext) callconv(.C) void,
    cacheFrame: ?*const fn (?*const Frame, c_int, ?*FrameContext) callconv(.C) void,
    setFilterError: ?*const fn ([*c]const u8, ?*FrameContext) callconv(.C) void,
    createFunction: ?*const fn (PublicFunction, ?*anyopaque, FreeFunctionData, ?*Core) callconv(.C) ?*Function,
    freeFunction: ?*const fn (?*Function) callconv(.C) void,
    addFunctionRef: ?*const fn (?*Function) callconv(.C) ?*Function,
    callFunction: ?*const fn (?*Function, ?*const Map, ?*Map) callconv(.C) void,
    createMap: ?*const fn () callconv(.C) ?*Map,
    freeMap: ?*const fn (?*Map) callconv(.C) void,
    clearMap: ?*const fn (?*Map) callconv(.C) void,
    copyMap: ?*const fn (?*const Map, ?*Map) callconv(.C) void,
    mapSetError: ?*const fn (?*Map, [*c]const u8) callconv(.C) void,
    mapGetError: ?*const fn (?*const Map) callconv(.C) [*c]const u8,
    mapNumKeys: ?*const fn (?*const Map) callconv(.C) c_int,
    mapGetKey: ?*const fn (?*const Map, c_int) callconv(.C) [*c]const u8,
    mapDeleteKey: ?*const fn (?*Map, [*c]const u8) callconv(.C) c_int,
    mapNumElements: ?*const fn (?*const Map, [*c]const u8) callconv(.C) c_int,
    mapGetType: ?*const fn (?*const Map, [*c]const u8) callconv(.C) c_int,
    mapSetEmpty: ?*const fn (?*Map, [*c]const u8, c_int) callconv(.C) c_int,
    mapGetInt: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) i64,
    mapGetIntSaturated: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) c_int,
    mapGetIntArray: ?*const fn (?*const Map, [*c]const u8, [*c]c_int) callconv(.C) [*c]const i64,
    mapSetInt: ?*const fn (?*Map, [*c]const u8, i64, c_int) callconv(.C) c_int,
    mapSetIntArray: ?*const fn (?*Map, [*c]const u8, [*c]const i64, c_int) callconv(.C) c_int,
    mapGetFloat: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) f64,
    mapGetFloatSaturated: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) f32,
    mapGetFloatArray: ?*const fn (?*const Map, [*c]const u8, [*c]c_int) callconv(.C) [*c]const f64,
    mapSetFloat: ?*const fn (?*Map, [*c]const u8, f64, c_int) callconv(.C) c_int,
    mapSetFloatArray: ?*const fn (?*Map, [*c]const u8, [*c]const f64, c_int) callconv(.C) c_int,
    mapGetData: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) [*c]const u8,
    mapGetDataSize: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) c_int,
    mapGetDataTypeHint: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) c_int,
    mapSetData: ?*const fn (?*Map, [*c]const u8, [*c]const u8, c_int, c_int, c_int) callconv(.C) c_int,
    mapGetNode: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) ?*Node,
    mapSetNode: ?*const fn (?*Map, [*c]const u8, ?*Node, c_int) callconv(.C) c_int,
    mapConsumeNode: ?*const fn (?*Map, [*c]const u8, ?*Node, c_int) callconv(.C) c_int,
    mapGetFrame: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) ?*const Frame,
    mapSetFrame: ?*const fn (?*Map, [*c]const u8, ?*const Frame, c_int) callconv(.C) c_int,
    mapConsumeFrame: ?*const fn (?*Map, [*c]const u8, ?*const Frame, c_int) callconv(.C) c_int,
    mapGetFunction: ?*const fn (?*const Map, [*c]const u8, c_int, [*c]c_int) callconv(.C) ?*Function,
    mapSetFunction: ?*const fn (?*Map, [*c]const u8, ?*Function, c_int) callconv(.C) c_int,
    mapConsumeFunction: ?*const fn (?*Map, [*c]const u8, ?*Function, c_int) callconv(.C) c_int,
    registerFunction: ?*const fn ([*c]const u8, [*c]const u8, [*c]const u8, PublicFunction, ?*anyopaque, ?*Plugin) callconv(.C) c_int,
    getPluginByID: ?*const fn ([*c]const u8, ?*Core) callconv(.C) ?*Plugin,
    getPluginByNamespace: ?*const fn ([*c]const u8, ?*Core) callconv(.C) ?*Plugin,
    getNextPlugin: ?*const fn (?*Plugin, ?*Core) callconv(.C) ?*Plugin,
    getPluginName: ?*const fn (?*Plugin) callconv(.C) [*c]const u8,
    getPluginID: ?*const fn (?*Plugin) callconv(.C) [*c]const u8,
    getPluginNamespace: ?*const fn (?*Plugin) callconv(.C) [*c]const u8,
    getNextPluginFunction: ?*const fn (?*PluginFunction, ?*Plugin) callconv(.C) ?*PluginFunction,
    getPluginFunctionByName: ?*const fn ([*c]const u8, ?*Plugin) callconv(.C) ?*PluginFunction,
    getPluginFunctionName: ?*const fn (?*PluginFunction) callconv(.C) [*c]const u8,
    getPluginFunctionArguments: ?*const fn (?*PluginFunction) callconv(.C) [*c]const u8,
    getPluginFunctionReturnType: ?*const fn (?*PluginFunction) callconv(.C) [*c]const u8,
    getPluginPath: ?*const fn (?*const Plugin) callconv(.C) [*c]const u8,
    getPluginVersion: ?*const fn (?*const Plugin) callconv(.C) c_int,
    invoke: ?*const fn (?*Plugin, [*c]const u8, ?*const Map) callconv(.C) ?*Map,
    createCore: ?*const fn (c_int) callconv(.C) ?*Core,
    freeCore: ?*const fn (?*Core) callconv(.C) void,
    setMaxCacheSize: ?*const fn (i64, ?*Core) callconv(.C) i64,
    setThreadCount: ?*const fn (c_int, ?*Core) callconv(.C) c_int,
    getCoreInfo: ?*const fn (?*Core, [*c]CoreInfo) callconv(.C) void,
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    logMessage: ?*const fn (c_int, [*c]const u8, ?*Core) callconv(.C) void,
    addLogHandler: ?*const fn (LogHandler, LogHandlerFree, ?*anyopaque, ?*Core) callconv(.C) ?*LogHandle,
    removeLogHandler: ?*const fn (?*LogHandle, ?*Core) callconv(.C) c_int,
};

pub extern fn getVapourSynthAPI(version: c_int) [*c]const API;
