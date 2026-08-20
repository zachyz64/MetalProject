//
//  PipelineBuilder.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/6/26.
//

import MetalKit

class PipelineBuilder {
    
    static func BuildPipeline(device: MTLDevice, library: MTLLibrary,
                              vs: String, fs: String, vertexDescriptor: MTLVertexDescriptor, depthEnabled: Bool) -> MTLRenderPipelineState {
        
        let pipeline: MTLRenderPipelineState
        
        // Set up the pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: vs)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: fs)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusBlendAlpha
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        if depthEnabled {
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        }
        
        do {
            try pipeline = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            return pipeline
        } catch {
            fatalError()
        }
    }
}
