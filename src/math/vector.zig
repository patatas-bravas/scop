const Vec3 = @Vector(3, f32);

pub fn cross(a: Vec3, b: Vec3) Vec3 {
    return .{
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}
pub fn normalise(vec: Vec3) Vec3 {
    const m = magnitude(vec);
    return .{ vec[0] / m, vec[1] / m, vec[2] / m };
}
pub fn magnitude(vec: Vec3) f32 {
    return @sqrt(@reduce(.Add, vec * vec));
}
