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
    for (mutable_signal, 0..) |val, i| {
        _ = val;
        const index: u16 = @intCast(i);
        const reversed: u16 = @bitReverse(index);
        print("index: {d}\n", .{index});
        print("reversed: {d}\n", .{reversed});

        // if (i <= reversed) {
        //mutable_signal[i] = mutable_signal[reversed];
        //mutable_signal[reversed] = val;
        //}
    }

    return signal;
}

test "power of two check" {
    const signal: [4]complex = .{ complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 2.0 }, complex{ .im = 0, .re = 3.0 }, complex{ .im = 0, .re = 4.0 } };
    const result = fft(4, signal);
    print("{any}", .{result});
}
