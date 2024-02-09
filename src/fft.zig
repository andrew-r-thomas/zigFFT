const std = @import("std");
const testing = std.testing;

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

    const twiddles = build_twiddles(
        twiddle_size,
        struct {
            reals: @Vector(twiddle_size, f32),
            ims: @Vector(twiddle_size, f32),
        },
    );

    const bit_rev = build_bit_rev(size);

    return struct {
        // TODO potentially move the comptime values into the struct,
        // so that we can get a sense of how much memory is being used
        // and potentially give the user more control over where that memory is allocated
        pub fn real_to_complex(signal: [size]f32) FFTData {
            var real_vec: SignalVec = signal;
            var im_vec: SignalVec = [_]f32{0.0} ** size;

            // first we do a bit reversal
            real_vec = @shuffle(f32, real_vec, undefined, bit_rev);

            // then we do the movie magic
            for (1..(@log2(n) + 1)) |i| {
                const m = std.math.pow(usize, 2, i);
                var k: usize = 0;

                // TODO: this while loop can be SIMDed
                while (k < size) : (k += m) {
                    var w = complex{ .im = 0, .re = 1 };
                    for (0..(m / 2)) |j| {
                        const temp = w.mul(complex{ .re = real_vec[k + j + (m / 2)], .im = im_vec[k + j + (m / 2)] });
                        const uemp = complex{ .re = real_vec[k + j], .im = im_vec[k + j] };

                        const first = uemp.add(temp);
                        const second = uemp.sub(temp);

                        real_vec[k + j] = first.re;
                        im_vec[k + j] = first.im;

                        real_vec[k + j + (m / 2)] = second.re;
                        im_vec[k + j + (m / 2)] = second.im;

                        // TODO put this in one vec, we can do this at comptime
                        w = w.mul(complex{ .re = twiddles.reals[i - 1], .im = twiddles.ims[i - 1] });
                    }
                }
            }

            return FFTData{
                .reals = real_vec,
                .imaginaries = im_vec,
            };
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

fn build_bit_rev(comptime size: usize) @Vector(size, usize) {
    var idxs: [size]usize = undefined;
    var current: usize = 0;
    for (0..(size / 2) - 1) |i| {
        _ = i;
        if (current == 0) {
            idxs[0] = 0;
            idxs[1] = size / 2;
            current = 2;
        } else {
            for (0..current) |j| {
                idxs[current + j] = idxs[j] + size / (current * 2);
            }
            current *= 2;
        }
    }

    const out: @Vector(size, usize) = idxs;
    return out;
}

test "power of two check" {
    try testing.expect(FFT(7) == FFTError.NonPowerOfTwo);
}

test "simple 8 point test" {
    const signal: [8]f32 = .{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const f = try FFT(8);
    const out = f.run(signal);
    const reals = out.reals;
    const ims = out.imaginaries;

    try testing.expect(std.mem.eql(f32, &reals, &[8]f32{ 28, -3.999999523162842, -4, -4, -4, -4, -4, -4 }));
    try testing.expect(std.mem.eql(f32, &ims, &[8]f32{ 0, 9.656853675842285, 3.999999761581421, 1.6568536758422852, 0, -1.6568536758422852, -3.999999761581421, -9.656853675842285 }));
}
