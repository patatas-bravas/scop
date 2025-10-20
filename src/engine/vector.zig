const std = @import("std");

pub const Vec3 = @Vector(3, f32);

pub const Vec4 = @Vector(4, f32);

pub fn printVec3(vec: Vec3) void {
    std.debug.print("v = {}", .{vec});
}

pub fn addScalar(a: Vec3, x: f32) Vec3 {
    return (a + @as(Vec3, @splat(x)));
}

pub fn mulScalar(a: Vec3, x: f32) Vec3 {
    return (a * @as(Vec3, @splat(x)));
}

pub fn add(a: Vec3, b: Vec3) Vec3 {
    return (a + b);
}

pub fn sub(a: Vec3, b: Vec3) Vec3 {
    return (b - a);
}

pub fn mul(a: Vec3, b: Vec3) Vec3 {
    return a * b;
}

pub fn magnitude(a: Vec3) f32 {
    return @sqrt(@reduce(.Add, a * a));
}

pub fn neg(a: Vec3) Vec3 {
    return -a;
}
