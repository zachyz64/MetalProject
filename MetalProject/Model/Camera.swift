//
//  Camera.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import Foundation

class Camera {
    var position: simd_float3
    var eulers: simd_float3
    
    var forward: simd_float3
    var right: simd_float3
    var up: simd_float3
    
    var view: simd_float4x4
    var projection: simd_float4x4
    
    init(position: simd_float3, eulers: simd_float3) {
        
        self.position   = position
        self.eulers     = eulers
        
        self.forward    = [0.0, 0.0, 0.0]
        self.right      = [0.0, 0.0, 0.0]
        self.up         = [0.0, 0.0, 0.0]
        
        self.view       = Matrix4x4.create_identity()
        self.projection = Matrix4x4.create_perspective_projection(fovy: 45,
                                                                  aspect: 800 / 600,
                                                                  near: 0.1,
                                                                  far: 30)
    }
    
    func update() {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            forward = [cos(eulers.y * .pi / 180.0) * cos(eulers.z * .pi / 180.0),
                       cos(eulers.y * .pi / 180.0) * sin(eulers.z * .pi / 180.0),
                       sin(eulers.y * .pi / 180.0)
            ]
            
            let globalUp: simd_float3 = [0.0, 0.0, 1.0]
            
            right = simd.normalize(simd.cross(globalUp, forward))
            up = simd.normalize(simd.cross(forward, right))
            
            view = Matrix4x4.create_lookat(eye: position,
                                           target: position + forward,
                                           worldUp: up)
        } else {
            forward = simd.normalize([0, 0, 0] - position)
            
            let globalUp: simd_float3 = [0, 0, 1]
            
            right = simd.normalize(simd.cross(globalUp, forward))
            up = simd.normalize(simd.cross(forward, right))
            
            view = Matrix4x4.create_lookat(eye: position,
                                           target: [0, 0, 0],
                                           worldUp: up)
        }
    }
    
    func move(amount: simd_float3) {
        position = position + amount.x * [forward.x, forward.y, 0.0]
                            + amount.y * [right.x, right.y, 0.0]
                            + amount.z * [0.0, 0.0, 1.0]
    }
    
    func rotateCamera(rightAmount: Float, upAmount: Float) {
        let length: Float = simd.length(position)
        position = length * simd.normalize(position + rightAmount * right + upAmount * up)
    }
}
