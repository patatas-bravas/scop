const std = @import("std");
const vector = @import("vector.zig");

const Vec3 = @Vector(3, f32);
const Mat4 = [4]@Vector(4, f32);

pub fn print(mat: Mat4) void {
    inline for (mat) |m| {
        std.debug.print("{}\n", .{m});
    }
}

pub fn createIdentity() Mat4 {
    var mat = std.mem.zeroes(Mat4);
    inline for (0..4) |i| {
        mat[i][i] = 1;
    }
    return mat;
}

pub fn createOrtho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
    if (left > right or bottom > top or near > far) unreachable;
    var mat = createIdentity();
    mat[0][0] = 2.0 / (right - left);
    mat[1][1] = 2.0 / (top - bottom);
    mat[2][2] = -2.0 / (far - near);

    mat[0][3] = -(right + left) / (right - left);
    mat[1][3] = -(top + bottom) / (top - bottom);
    mat[2][3] = -(far + near) / (far - near);
    return mat;
}

pub fn createPerspective(degrees: f32, aspect: f32, near: f32, far: f32) Mat4 {
    const fov_radians = degrees * std.math.pi / 180.0;
    const tan_half_fov = @tan(fov_radians / 2.0);
    var mat = std.mem.zeroes(Mat4);

    mat[0][0] = 1.0 / (aspect * tan_half_fov);
    mat[1][1] = 1.0 / tan_half_fov;
    mat[2][2] = -(far + near) / (far - near);
    mat[2][3] = -1.0;
    mat[3][2] = -(2.0 * far * near) / (far - near);

    return mat;
}

pub fn createLookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
    const forward = vector.normalise(center - eye);
    const right = vector.normalise(vector.cross(forward, up));
    const newUp = vector.cross(right, forward);

    var mat = createIdentity();
    mat[0][0] = right[0];
    mat[1][0] = right[1];
    mat[2][0] = right[2];

    mat[0][1] = newUp[0];
    mat[1][1] = newUp[1];
    mat[2][1] = newUp[2];

    mat[0][2] = -forward[0];
    mat[1][2] = -forward[1];
    mat[2][1] = -forward[2];

    mat[3][0] = -(@reduce(.Add, right * eye));
    mat[3][1] = -(@reduce(.Add, newUp * eye));
    mat[3][2] = @reduce(.Add, forward * eye);

    return mat;
}

pub fn scalingScalar(mat: Mat4, x: f32) Mat4 {
    var result = mat;
    inline for (0..3) |i| {
        result[i][i] *= x;
    }
    return result;
}

pub fn scalingVec(mat: Mat4, vec: Vec3) Mat4 {
    var result = mat;
    inline for (0..3) |i| {
        result[i][i] *= vec[i];
    }
    return result;
}

pub fn translateScalar(mat: Mat4, x: f32) Mat4 {
    var result = mat;
    inline for (0..3) |i| {
        result[3][i] += x;
    }
    return result;
}

pub fn translateVec(mat: Mat4, vec: Vec3) Mat4 {
    var result = mat;
    inline for (0..3) |i| {
        result[3][i] += vec[i];
    }
    return result;
}

pub fn rotationXMat(mat: Mat4, theta: f32) Mat4 {
    var result = mat;
    result[1][1] = @cos(theta);
    result[1][2] = -@sin(theta);
    result[2][1] = @sin(theta);
    result[2][2] = @cos(theta);
    return result;
}

pub fn rotationYMat(mat: Mat4, theta: f32) Mat4 {
    var result = mat;
    result[0][0] = @cos(theta);
    result[0][2] = @sin(theta);
    result[2][0] = -@sin(theta);
    result[2][2] = @cos(theta);
    return result;
}

pub fn rotationZMat(mat: Mat4, theta: f32) Mat4 {
    var result = mat;
    result[0][0] = @cos(theta);
    result[0][1] = -@sin(theta);
    result[1][0] = @sin(theta);
    result[1][1] = @cos(theta);
    return result;
}
