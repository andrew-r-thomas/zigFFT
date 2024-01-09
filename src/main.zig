const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const complex = std.math.Complex(f32);

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

    return signal;
}

test "power of two check" {
    const signal: [8]complex = .{ complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 2.0 }, complex{ .im = 0, .re = 3.0 }, complex{ .im = 0, .re = 4.0 }, complex{ .im = 0, .re = 5.0 }, complex{ .im = 0, .re = 6.0 }, complex{ .im = 0, .re = 7.0 }, complex{ .im = 0, .re = 8.0 } };
    const result = fft(8, signal);
    print("{any}", .{result});
}
