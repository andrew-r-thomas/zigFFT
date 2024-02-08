const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;
const print = std.debug.print;
const fft = @import("fft.zig");

test "power of two check" {
    try testing.expect(fft.FFT(7) == fft.FFTError.NonPowerOfTwo);
}

test "simple 8 point test" {
    const signal: [8]f32 = .{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const f = try fft.FFT(8);
    const out = f.run(&signal);
    const reals = out.reals;
    const ims = out.imaginaries;

    try testing.expect(std.mem.eql(f32, &reals, &[8]f32{ 28, -3.999999523162842, -4, -4, -4, -4, -4, -4 }));
    try testing.expect(std.mem.eql(f32, &ims, &[8]f32{ 0, 9.656853675842285, 3.999999761581421, 1.6568536758422852, 0, -1.6568536758422852, -3.999999761581421, -9.656853675842285 }));
}

// TODO benchmarking
