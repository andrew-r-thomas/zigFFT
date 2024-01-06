const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// TODO figure out how to make size not have to be put in explicitly
pub fn create_FFT(comptime size: usize, comptime signal: [size]f32) type {
    assert(size % 2 == 0);
    assert(size == signal.len);

    return struct {
        size: size,
        signal: signal,
        fn do_FFT() void {}
    };
}

test "power of two check" {
    const signal_good = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const signal_bad = [5]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const fft_bad = create_FFT(5, signal_bad);
    _ = fft_bad;
    const fft = create_FFT(4, signal_good);
    _ = fft;
    try testing.expect(add(3, 7) == 10);
}
