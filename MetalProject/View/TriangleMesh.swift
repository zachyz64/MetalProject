//
//  TriangleMesh.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import MetalKit

class TriangleMesh {
    
    let vertexBuffer: MTLBuffer
    
    init(metalDevice: MTLDevice) {
        
        let vertices: [Vertex] = [
            Vertex(position: [-0.75, 0.0, -0.75], color: [1.0, 0.0, 0.0, 1.0]),
            Vertex(position: [0.75,  0.0, -0.75], color: [0.0, 1.0, 0.0, 1.0]),
            Vertex(position: [0.0,  0.0,  0.75], color: [0.0, 0.0, 1.0, 1.0])
        ]
        
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                              length: vertices.count * MemoryLayout<Vertex>.stride,
                                              options: [])!
    }
}
