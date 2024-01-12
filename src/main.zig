const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;
const print = std.debug.print;
const fft = @import("fft.zig");

// test "power of two check" {
//     const signal: [7]f32 = .{ 0, 1, 2, 3, 4, 5, 6 };
//     try testing.expect(fft(7, signal) == FFTError.NonPowerOfTwo);
// }

test "simple 8 point test" {
    const signal: [8]f32 = .{ 0, 1, 2, 3, 4, 5, 6, 7 };
    print("dude why", .{});
    const f = fft.create_FFT(8);
    const out = f.run(signal);
    try print("\n this is it: {any}", .{out});
}
