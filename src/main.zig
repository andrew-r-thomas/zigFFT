const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const complex = std.math.Complex(f32);

fn fft(comptime size: usize, signal: [size]complex) [size]complex {
    var out: [size]complex = undefined;
    const log2 = @log2(@as(f32, size));

    // first we do a bit reversal
    for (signal, 0..) |val, i| {
        _ = val;
        for (0..log2) |j| {
            const match = ((1 << j) & i) == 0;
            _ = match;
            var new = undefined;
            new |= (1 << log2 - 1 - j);
        }
    }

    return out;
}

test "power of two check" {
    const signal: [4]complex = .{ complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 1.0 }, complex{ .im = 0, .re = 1.0 } };
    const result = fft(4, signal);
    print("{any}", .{result});
}
