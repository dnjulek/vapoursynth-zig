//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VSScript4.h

const vs = @import("vapoursynth4.zig");

pub const VSSCRIPT_API_MAJOR: c_int = 4;
pub const VSSCRIPT_API_MINOR: c_int = 2;
pub const VSSCRIPT_API_VERSION: c_int = vs.makeVersion(VSSCRIPT_API_MAJOR, VSSCRIPT_API_MINOR);

pub const VSScript = opaque {};

pub const API = extern struct {
    /// Returns the highest supported VSSCRIPT_API_VERSION
    getAPIVersion: ?*const fn () callconv(.C) c_int,
    /// Convenience function for retrieving a VSAPI pointer without having to use the VapourSynth library. Always pass VAPOURSYNTH_API_VERSION
    getVSAPI: ?*const fn (version: c_int) callconv(.C) ?*const vs.API,
    /// Providing a pre-created core is useful for setting core creation flags, log callbacks, preload specific plugins and many other things.
    /// You must create a VSScript object before evaluating a script. Always takes ownership of the core even on failure. Returns NULL on failure.
    /// Pass NULL to have a core automatically created with the default options.
    createScript: ?*const fn (core: ?*vs.Core) callconv(.C) ?*VSScript,
    /// The core is valid as long as the environment exists, return NULL on error
    getCore: ?*const fn (handle: ?*VSScript) callconv(.C) ?*vs.Core,
    /// Evaluates a script passed in the buffer argument. The scriptFilename is only used for display purposes.
    /// in Python it means that the main module won't be unnamed in error messages. Returns 0 on success.
    /// Note that calling any function other than getError() and freeScript() on a VSScript object in the error state will result in undefined behavior.
    evaluateBuffer: ?*const fn (handle: ?*VSScript, buffer: [*]const u8, scriptFilename: [*]const u8) callconv(.C) c_int,
    /// Convenience version of the above function that loads the script from scriptFilename and passes as the buffer to evaluateBuffer
    evaluateFile: ?*const fn (handle: ?*VSScript, scriptFilename: [*]const u8) callconv(.C) c_int,
    /// Returns NULL on success, otherwise an error message
    getError: ?*const fn (handle: ?*VSScript) callconv(.C) [*c]const u8,
    /// Returns the script's reported exit code
    getExitCode: ?*const fn (handle: ?*VSScript) callconv(.C) c_int,
    /// Fetches a variable of any VSMap storable type set in a script. It is stored in the key with the same name in dst. Returns 0 on success
    getVariable: ?*const fn (handle: ?*VSScript, name: [*]const u8, dst: ?*vs.Map) callconv(.C) c_int,
    /// Sets all keys in the provided VSMap as variables in the script. Returns 0 on success
    setVariables: ?*const fn (handle: ?*VSScript, vars: ?*const vs.Map) callconv(.C) c_int,
    /// The returned nodes must be freed using freeNode() before calling freeScript() since they may depend on data in the VSScript environment.
    /// Returns NULL if no node was set as output in the script. Index 0 is used by default in scripts and other values are rarely used.
    getOutputNode: ?*const fn (handle: ?*VSScript, index: c_int) callconv(.C) ?*vs.Node,
    getOutputAlphaNode: ?*const fn (handle: ?*VSScript, index: c_int) callconv(.C) ?*vs.Node,
    getAltOutputMode: ?*const fn (handle: ?*VSScript, index: c_int) callconv(.C) c_int,
    freeScript: ?*const fn (handle: ?*VSScript) callconv(.C) void,

    /// Set whether or not the working directory is temporarily changed to the same
    /// location as the script file when evaluateFile is called. Off by default.
    evalSetWorkingDir: ?*const fn (handle: ?*VSScript, set_cwd: c_int) callconv(.C) void,
    /// Write a list of set output index values to dst but at most size values.
    /// Always returns the total number of available output index values.
    getAvailableOutputNodes: ?*const fn (handle: ?*VSScript, size: c_int, dst: *c_int) callconv(.C) c_int,
};

pub extern fn getVSScriptAPI(version: c_int) ?*const API;
