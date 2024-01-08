const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const complex = std.math.Complex;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

const signal_type = complex(f32);

// TODO figure out how to make size not have to be put in explicitly
pub fn create_FFT(comptime size: usize, comptime signal: [size]signal_type) type {
    assert(size % 2 == 0);
    assert(size == signal.len);

    return struct {
        size: size,
        signal: signal,
        fn do_FFT(current_signal: []signal_type) []signal_type {
            if (current_signal.len == 1) return current_signal;
        }
    };
}

test "power of two check" {
    const signal_bad = [5]signal_type{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const fft_bad = create_FFT(5, signal_bad);
    try testing.expect(add(3, 7) == 10);
}
