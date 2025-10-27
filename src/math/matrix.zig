const std = @import("std");

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
