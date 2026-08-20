//
//  ScreenQuad.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/21/26.
//

import MetalKit

class ScreenQuad {
    
    var vertexBuffer: MTLBuffer?
    var vertexCount: Int
    
    init(device: MTLDevice) {
        
        let data: [SimpleVertex] = [
            SimpleVertex(position: [-1.0, -1.0]),
            SimpleVertex(position: [ 1.0, -1.0]),
            SimpleVertex(position: [ 1.0,  1.0]),
            
            SimpleVertex(position: [ 1.0,  1.0]),
            SimpleVertex(position: [-1.0,  1.0]),
            SimpleVertex(position: [-1.0, -1.0]),
        ]
        
        vertexBuffer = device.makeBuffer(bytes: data,
                                         length: data.count * MemoryLayout<SimpleVertex>.stride)
        vertexCount = 6
    }
}
