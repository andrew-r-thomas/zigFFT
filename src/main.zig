const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const complex = std.math.Complex;
const print = std.debug.print;

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

            var evens: signal_type[current_signal.len / 2] = undefined;
            var odds: signal_type[current_signal.len / 2] = undefined;
            for (current_signal, 0..) |value, i| {
                if (i % 2 == 0) {
                    evens[i / 2] = value;
                } else {
                    odds[@floor(i / 2)] = value;
                }
            }

            const fft_e = do_FFT(evens);
            const fft_o = do_FFT(odds);

            return fft_e + fft_o;
        }
    };
}

test "power of two check" {
    const signal: [4]signal_type = .{ signal_type{ .im = 0, .re = 1.0 }, signal_type{ .im = 0, .re = 1.0 }, signal_type{ .im = 0, .re = 1.0 }, signal_type{ .im = 0, .re = 1.0 } };
    const fft = create_FFT(4, signal);
    // const result = fft.do_FFT(&signal);
    print("{any}", .{fft.signal});
}
