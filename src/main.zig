const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;
const print = std.debug.print;

const complex = std.math.Complex(f32);

const FFTError = error{
    NonPowerOfTwo,
    LargeSignal,
};

fn fft(comptime size: usize, signal: [size]complex) ![size]complex {
    // make sure that we have a power of two
    // and that the indecies can be represented as u16 for bit reversal
    if (size % 2 != 0) return FFTError.NonPowerOfTwo;
    if (size <= 65535) return FFTError.LargeSignal;

    var mutable_signal = signal;

    // first we do a bit reversal
    var newIdx: [size / 2]usize = [_]usize{0} ** (size / 2);
    var len: u16 = 1;
    while (newIdx[(size / 2) - 1] == 0) : (len *= 2) {
        const add = size / (len * 2);

        for (len..(2 * len)) |i| {
            newIdx[i] = newIdx[i - len] + add;
            const temp = mutable_signal[i];
            mutable_signal[i] = mutable_signal[newIdx[i]];
            mutable_signal[newIdx[i]] = temp;
        }
    }

    // then we do the movie magic
    const n: f32 = @floatFromInt(size);
    for (1..(@log2(n) + 1)) |i| {
        const m = std.math.pow(usize, 2, i);
        const m_float: f32 = @floatFromInt(m);
        const x: f32 = (-2 * std.math.pi) / m_float;
        const twiddle = complex{ .re = @cos(x), .im = @sin(x) };

        var k: usize = 0;
        while (k < size) : (k += m) {
            var w = complex{ .im = 0, .re = 1 };
            for (0..(m / 2)) |j| {
                const temp = w.mul(mutable_signal[k + j + (m / 2)]);
                const uemp = mutable_signal[k + j];
                mutable_signal[k + j] = uemp.add(temp);
                mutable_signal[k + j + (m / 2)] = uemp.sub(temp);
                w = w.mul(twiddle);
            }
        }
    }

    return mutable_signal;
}

test "power of two check" {
    const signal: [7]complex = .{ complex{ .im = 0, .re = 0.0 }, complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 2.0 }, complex{ .im = 0, .re = 3.0 }, complex{ .im = 0, .re = 4.0 }, complex{ .im = 0, .re = 5.0 }, complex{ .im = 0, .re = 6.0 } };
    try testing.expect(fft(7, signal) == FFTError.NonPowerOfTwo);
}

test "large input check" {}
