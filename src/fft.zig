const std = @import("std");

const complex = std.math.Complex(f32);

pub const FFTError = error{
    NonPowerOfTwo,
};

pub fn FFT(comptime size: usize) !type {
    // make sure that we have a power of two
    if (size % 2 != 0) return FFTError.NonPowerOfTwo;

    const SignalVec: type = @Vector(size, f32);

    const FFTData = struct {
        reals: [size]f32,
        imaginaries: [size]f32,
    };

    const n: f32 = @floatFromInt(size);
    const twiddle_size: usize = @log2(n);

    const twiddles =
        build_twiddles(
        twiddle_size,
        struct {
            reals: @Vector(twiddle_size, f32),
            ims: @Vector(twiddle_size, f32),
        },
    );

    return struct {
        pub fn run(signal: [size]f32) FFTData {
            var real_vec: SignalVec = undefined;
            _ = real_vec;
            var im_vec: SignalVec = undefined;
            _ = im_vec;

            var out = FFTData{ .reals = signal, .imaginaries = [_]f32{0} ** size };

            // first we do a bit reversal
            var newIdx: [size / 2]usize = [_]usize{0} ** (size / 2);
            var len: u16 = 1;
            while (newIdx[(size / 2) - 1] == 0) : (len *= 2) {
                const add = size / (len * 2);

                for (len..(2 * len)) |i| {
                    newIdx[i] = newIdx[i - len] + add;
                    const temp = out.reals[i];
                    out.reals[i] = out.reals[newIdx[i]];
                    out.reals[newIdx[i]] = temp;
                }
            }

            // then we do the movie magic
            for (1..(@log2(n) + 1)) |i| {
                const m = std.math.pow(usize, 2, i);
                var k: usize = 0;

                // TODO: this while loop can be SIMDed
                while (k < size) : (k += m) {
                    var w = complex{ .im = 0, .re = 1 };
                    for (0..(m / 2)) |j| {
                        const temp = w.mul(complex{ .re = out.reals[k + j + (m / 2)], .im = out.imaginaries[k + j + (m / 2)] });
                        const uemp = complex{ .re = out.reals[k + j], .im = out.imaginaries[k + j] };

                        const first = uemp.add(temp);
                        const second = uemp.sub(temp);

                        out.reals[k + j] = first.re;
                        out.imaginaries[k + j] = first.im;

                        out.reals[k + j + (m / 2)] = second.re;
                        out.imaginaries[k + j + (m / 2)] = second.im;

                        // TODO
                        w = w.mul(complex{ .re = twiddles.reals[i - 1], .im = twiddles.ims[i - 1] });
                    }
                }
            }

            return out;
        }
    };
}

fn build_twiddles(comptime twiddle_size: usize, comptime twiddle_type: type) twiddle_type {
    var twiddle_table: twiddle_type = twiddle_type{
        .reals = undefined,
        .ims = undefined,
    };

    // precompute twiddle factors
    for (1..(twiddle_size + 1)) |i| {
        const m = std.math.pow(usize, 2, i);
        const m_float: f32 = @floatFromInt(m);
        const x: f32 = (-2 * std.math.pi) / m_float;
        twiddle_table.reals[i - 1] = @cos(x);
        twiddle_table.ims[i - 1] = @sin(x);
    }

    return twiddle_table;
}
