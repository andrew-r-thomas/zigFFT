const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const complex = std.math.Complex(f32);
const cos = std.math.cos;
const sin = std.math.sin;

fn fft(comptime size: usize, signal: [size]complex) [size]complex {
    // make sure that we have a power of two
    // and that the indecies can be represented as u16 for bit reversal
    assert(size % 2 == 0);
    assert(size <= 65535);

    var out: [size]complex = undefined;
    _ = out;

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
    // TODO: lots of type conversion
    const n: f32 = @floatFromInt(size);
    for (1..@log2(n)) |i| {
        const m = std.math.pow(usize, 2, i);
        const m_float: f32 = @floatFromInt(m);
        const x: f32 = (-2 * std.math.pi) / m_float;
        const twiddle = complex{ .re = cos(x), .im = sin(x) };

        var k: usize = 1;
        while (k < (size - 1)) : (k += m) {
            var w = complex{ .im = 0, .re = 1 };
            for (0..(m / 2 - 1)) |j| {
                const temp = w.mul(mutable_signal[k + j + (m / 2)]);
                const uemp = mutable_signal[k + j];
                mutable_signal[k + j] = temp.add(uemp);
                mutable_signal[k + j + (m / 2)] = uemp.sub(temp);
                w = w.mul(twiddle);
            }
        }
    }

    return mutable_signal;
}

test "power of two check" {
    const signal: [8]complex = .{ complex{ .im = 0, .re = 0.0 }, complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 2.0 }, complex{ .im = 0, .re = 3.0 }, complex{ .im = 0, .re = 4.0 }, complex{ .im = 0, .re = 5.0 }, complex{ .im = 0, .re = 6.0 }, complex{ .im = 0, .re = 7.0 } };
    const result = fft(8, signal);
    print("\n", .{});
    for (result) |num| {
        print("{any}\n", .{num});
    }
}
