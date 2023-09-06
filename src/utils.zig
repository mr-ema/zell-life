const std = @import("std");
const rand = std.rand;
const time = std.time;

pub fn randomInRange(comptime T: type, min: T, max: T) T {
    const time_sample: u128 = @bitCast(time.nanoTimestamp());
    const seed: u64 = @truncate(time_sample);
    var prng = rand.DefaultPrng.init(seed);

    const result = prng.random().intRangeAtMost(T, min, max);
    return result;
}
