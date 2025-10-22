const std = @import("std");

pub fn print(a: anytype) void {
    std.debug.print("{}", .{a});
}

pub fn addScalar(a: anytype, x: f32) @TypeOf(a) {
    return a + @as(@TypeOf(a), @splat(x));
}

pub fn mulScalar(a: anytype, x: f32) @TypeOf(a) {
    return a * x;
}

pub fn add(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a + b;
}

pub fn mul(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a * b;
}

pub fn magnitude(a: anytype) f32 {
    return @sqrt(@reduce(.Add, a * a));
}
