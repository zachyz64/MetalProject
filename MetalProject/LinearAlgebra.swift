//
//  LinearAlgebra.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import Foundation
import simd

class Matrix4x4 {
    
    static func create_identity() -> simd_float4x4 {
        return simd_float4x4([1, 0, 0, 0],
                             [0, 1, 0, 0],
                             [0, 0, 1, 0],
                             [0, 0, 0, 1])
    }
    
    static func create_from_translation(_ translation: simd_float3) -> simd_float4x4 {
        return simd_float4x4(
            [1,             0,             0,             0],
            [0,             1,             0,             0],
            [0,             0,             1,             0],
            [translation.x, translation.y, translation.z, 1]
        )
    }
    
    static func create_from_rotation(_ eulers: simd_float3) -> simd_float4x4 {
        let gamma: Float = eulers.x * .pi / 180.0
        let beta: Float = eulers.y * .pi / 180.0
        let alpha: Float = eulers.z * .pi / 180.0
        
        return create_from_z_rotation(alpha) * create_from_y_rotation(beta) * create_from_x_rotation(gamma)
    }
    
    static func create_from_scale(_ scale: simd_float3) -> simd_float4x4 {
        return simd_float4x4(
            [scale.x,  0,       0,       0],
            [0,        scale.y, 0,       0],
            [0,        0,       scale.z, 0],
            [0,        0,       0,       1]
        )
    }
    
    static func create_lookat(eye: simd_float3, target: simd_float3, worldUp: simd_float3) -> simd_float4x4 {
        let forward: simd_float3 = simd.normalize(target - eye)
        let right: simd_float3 = simd.normalize(simd.cross(worldUp, forward))
        let up: simd_float3 = simd.normalize(simd.cross(forward, right))
        
        return simd_float4x4(
            [-right.x,               up.x,               forward.x,             0],
            [-right.y,               up.y,               forward.y,             0],
            [-right.z,               up.z,               forward.z,             0],
            [ simd.dot(right, eye), -simd.dot(up, eye), -simd.dot(forward,eye), 1]
        )
    }
    
    static func create_perspective_projection(fovy: Float, aspect: Float, near: Float, far: Float) -> simd_float4x4 {
        
        let tangent: Float = tan(fovy * .pi / 360.0)
        let A: Float = 1 / (aspect * tangent)
        let B: Float = 1 / tangent
        let C: Float = far / (far - near)
        let D: Float = 1
        let E: Float = -near * far / (far - near)
        
        return simd_float4x4(
            [A, 0, 0, 0],
            [0, B, 0, 0],
            [0, 0, C, D],
            [0, 0, E, 0]
        )
    }
    
    static private func create_from_x_rotation(_ theta: Float) -> simd_float4x4 {
        return simd_float4x4(
            [1,  0,          0,          0],
            [0,  cos(theta), sin(theta), 0],
            [0, -sin(theta), cos(theta), 0],
            [0,  0,          0,          1]
        )
    }
    
    static private func create_from_y_rotation(_ theta: Float) -> simd_float4x4 {
        return simd_float4x4(
            [cos(theta), 0, -sin(theta), 0],
            [0,          1,  0,          0],
            [sin(theta), 0,  cos(theta), 0],
            [0,          0,  0,          1]
        )
    }
    
    static private func create_from_z_rotation(_ theta: Float) -> simd_float4x4 {
        return simd_float4x4(
            [ cos(theta),  sin(theta), 0, 0],
            [-sin(theta),  cos(theta), 0, 0],
            [ 0,           0,          1, 0],
            [ 0,           0,          0, 1]
        )
    }
}
