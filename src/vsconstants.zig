//! https://github.com/vapoursynth/vapoursynth/blob/master/include/VSConstants4.h
//!

pub const ColorRange = enum(c_int) {
    FULL = 0,
    LIMITED = 1,
};

pub const ChromaLocation = enum(c_int) {
    LEFT = 0,
    CENTER = 1,
    TOP_LEFT = 2,
    TOP = 3,
    BOTTOM_LEFT = 4,
    BOTTOM = 5,
};

pub const FieldBased = enum(c_int) {
    PROGRESSIVE = 0,
    BOTTOM = 1,
    TOP = 2,
};

pub const MatrixCoefficient = enum(c_int) {
    RGB = 0,
    BT709 = 1,
    UNSPECIFIED = 2,
    FCC = 4,
    BT470_BG = 5,
    /// Equivalent to 5
    ST170_M = 6,
    ST240_M = 7,
    YCGCO = 8,
    BT2020_NCL = 9,
    BT2020_CL = 10,
    CHROMATICITY_DERIVED_NCL = 12,
    CHROMATICITY_DERIVED_CL = 13,
    ICTCP = 14,
};

pub const TransferCharacteristics = enum(c_int) {
    BT709 = 1,
    UNSPECIFIED = 2,
    BT470_M = 4,
    BT470_BG = 5,
    /// Equivalent to 1
    BT601 = 6,
    ST240_M = 7,
    LINEAR = 8,
    LOG_100 = 9,
    LOG_316 = 10,
    IEC_61966_2_4 = 11,
    IEC_61966_2_1 = 13,
    /// Equivalent to 1
    BT2020_10 = 14,
    /// Equivalent to 1
    BT2020_12 = 15,
    ST2084 = 16,
    ARIB_B67 = 18,
};

pub const ColorPrimaries = enum(c_int) {
    BT709 = 1,
    UNSPECIFIED = 2,
    BT470_M = 4,
    BT470_BG = 5,
    ST170_M = 6,
    /// Equivalent to 6
    ST240_M = 7,
    FILM = 8,
    BT2020 = 9,
    ST428 = 10,
    ST431_2 = 11,
    ST432_1 = 12,
    EBU3213_E = 22,
};

pub const DataType = enum(c_int) {
    U8 = 1,
    U16 = 2,
    F32 = 4,
};
