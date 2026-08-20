//
//  BrightBillboard.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/13/26.
//

import Foundation

class BrightBillboard {
    
    var position: simd_float3
    var model: simd_float4x4
    var color: simd_float3
    var t: Float
    var rotationCenter: simd_float3
    var pathRadius: Float
    var pathPhi: Float
    var angularVelocity: Float
    
    init(position: simd_float3, color: simd_float3, rotationCenter: simd_float3, pathRadius: Float, pathPhi: Float, angularVelocity: Float) {
        self.position = position
        self.model = Matrix4x4.create_identity()
        self.color = color
        self.t = 0
        self.rotationCenter = rotationCenter
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.angularVelocity = angularVelocity
    }
    
    func update(viewerPosition: simd_float3) {
        position.x = rotationCenter.x + pathRadius * cos(t) * sin(pathPhi * .pi / 180.0)
        position.y = rotationCenter.y + pathRadius * sin(t) * sin(pathPhi * .pi / 180.0)
        position.z = rotationCenter.z + pathRadius * cos(pathPhi * .pi / 180.0)
        
        t += angularVelocity * 0.1
        if t > (2.0 * .pi) {
            t -= 2.0 * .pi
        }
        
        let selfToViewer: simd_float3 = viewerPosition - position
        let theta: Float = simd.atan2(selfToViewer.y, selfToViewer.x) * 180.0 / .pi
        let horizontalDistance: Float = sqrtf(selfToViewer.x * selfToViewer.x + selfToViewer.y * selfToViewer.y)
        let phi: Float = -simd.atan2(selfToViewer.z, horizontalDistance) * 180.0 / .pi
        model = Matrix4x4.create_from_rotation([0.0, phi, theta])
        model = Matrix4x4.create_from_translation(position) * model
    }
}
