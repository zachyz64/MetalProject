//
//  Actor.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/12/26.
//

import Foundation

class Actor {
    
    var transform: TransformComponent
    var model: simd_float4x4
    
    init(_ transform: TransformComponent) {
        self.transform = transform
        self.model = Matrix4x4.create_identity()
    }
    
    func update() {
        model = Matrix4x4.create_from_scale(transform.scale)
        model = Matrix4x4.create_from_rotation(transform.eulers) * model
        model = Matrix4x4.create_from_translation(transform.position) * model
    }
}
