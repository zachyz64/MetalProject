//
//  Light.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/11/26.
//

import Foundation

enum LightType {
    case UNDEFINED
    case DIRECTIONAL
    case SPOTLIGHT
    case POINTLIGHT
}

class Light {
    
    var type: LightType
    var color: simd_float3
    var position: simd_float3?
    var forward: simd_float3?
    var eulers: simd_float3?
    var t: Float?
    var rotationCenter: simd_float3?
    var pathRadius: Float?
    var pathPhi: Float?
    var angularVelocity: Float?
    
    init(color: simd_float3) {
        self.color = color
        self.type = LightType.UNDEFINED
    }
    
    func declareDirectional(eulers: simd_float3) {
        self.type = LightType.DIRECTIONAL
        self.eulers = eulers
    }
    
    func declareSpotlight(position: simd_float3, eulers: simd_float3) {
        self.type = LightType.SPOTLIGHT
        self.position = position
        self.eulers = eulers
        self.t = 0.0
    }
    
    func declarePointlight(rotationCenter: simd_float3, pathRadius: Float, pathPhi: Float, angularVelocity: Float) {
        self.type = LightType.POINTLIGHT
        self.position = rotationCenter
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.angularVelocity = angularVelocity
        self.t = 0.0
        self.rotationCenter = rotationCenter
    }
    
    func update() {
        if type == LightType.DIRECTIONAL {
            
            forward = [
                cos(eulers!.z * .pi / 180.0) * sin(eulers!.y * .pi / 180.0),
                sin(eulers!.z * .pi / 180.0) * sin(eulers!.y * .pi / 180.0),
                cos(eulers!.y * .pi / 180.0)
            ]
            
        } else if type == LightType.SPOTLIGHT {
            
            eulers!.y += 1
            if eulers!.y > 360 {
                eulers!.y -= 360
            }
            
            forward = [
                cos(eulers!.z * .pi / 180.0) * sin(eulers!.y * .pi / 180.0),
                sin(eulers!.z * .pi / 180.0) * sin(eulers!.y * .pi / 180.0),
                cos(eulers!.y * .pi / 180.0)
            ]
            
        } else if type == LightType.POINTLIGHT {
            
            position!.x = rotationCenter!.x + pathRadius! * cos(t!) * sin(pathPhi! * .pi / 180.0)
            position!.y = rotationCenter!.y + pathRadius! * sin(t!) * sin(pathPhi! * .pi / 180.0)
            //position!.z = rotationCenter!.z + pathRadius! * cos(pathPhi! * .pi / 180.0)
            
            t! += angularVelocity! * 0.1
            if t! > (2.0 * .pi) {
                t! -= 2.0 * .pi
            }
        }
    }
}
