const std = @import("std");

const Vec3 = @Vector(3, f32);
const Vec4 = @Vector(4, f32);
const Mat4 = [4]@Vector(4, f32);

pub fn printMat(mat: Mat4) void {
    inline for (0..4) |i| {
        std.debug.print("{}\n", .{mat[i]});
    }
}
pub fn createIdentityMat() Mat4 {
    var mat = std.mem.zeroes(Mat4);
    inline for (0..4) |i| {
        mat[i][i] = 1;
    }
    return mat;
}

pub fn mulVecMat(mat: Mat4, vec: Vec4) Vec4 {
    var result: @Vector(4, f32) = undefined;
    inline for (0..4) |i| {
        result[i] =
            mat[i][0] * vec[0] +
            mat[i][1] * vec[1] +
            mat[i][2] * vec[2] +
            mat[i][3] * vec[3];
    }
    return result;
}

pub fn mulScalarMat(mat: Mat4, x: f32) Mat4 {
    var result = mat;
    inline for (0..3) |i| {
        result[i][i] *= x;
    }
    return result;
}

pub fn transMat(mat: Mat4, vec: Vec4) Mat4 {
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

pub fn magnitudeVec(vec: Vec4) f32 {
    return @sqrt(@reduce(.Add, vec * vec));
}
