//
//  SimpleComponent.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import Foundation

class TransformComponent {
    
    var position: simd_float3
    var eulers: simd_float3
    var scale: simd_float3
    
    var model: simd_float4x4
    
    init(position: simd_float3, eulers: simd_float3, scale: simd_float3) {
        self.position = position
        self.eulers = eulers
        self.scale = scale
        self.model = Matrix4x4.create_identity()
    }
    
    func update() {
        model = Matrix4x4.create_from_scale(scale)
        model = Matrix4x4.create_from_rotation(eulers) * model
        model = Matrix4x4.create_from_translation(position) * model
    }
}
