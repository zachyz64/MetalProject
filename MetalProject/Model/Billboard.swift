//
//  Billboard.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/12/26.
//

import Foundation

class Billboard {
    
    var transform: TransformComponent
    var model: simd_float4x4
    
    init(_ transform: TransformComponent) {
        self.transform = transform
        self.model = Matrix4x4.create_identity()
    }
    
    func update(viewerPosition: simd_float3) {
        let selfToViewer: simd_float3 = viewerPosition - transform.position
        let theta: Float = simd.atan2(selfToViewer.y, selfToViewer.x) * 180.0 / .pi
        
        let horizontalDistance: Float = sqrtf(selfToViewer.x * selfToViewer.x + selfToViewer.y * selfToViewer.y)
        let phi: Float = -simd.atan2(selfToViewer.z, horizontalDistance) * 180.0 / .pi
        
        transform.eulers.y = phi
        transform.eulers.z = theta
        
        model = Matrix4x4.create_from_scale(transform.scale)
        model = Matrix4x4.create_from_rotation([0, phi, theta]) * model
        model = Matrix4x4.create_from_translation(transform.position) * model
    }
}
