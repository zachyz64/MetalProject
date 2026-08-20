//
//  RenderPass.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/21/26.
//

import MetalKit

class RenderPass {
    
    let colorBuffer: MTLTexture
    let colorBufferSampler: MTLSamplerState
    
    let depthBuffer: MTLTexture
    let depthStencilState: MTLDepthStencilState
    
    let renderPassDescriptor: MTLRenderPassDescriptor
    
    init(device: MTLDevice, width: Int, height: Int) {
        
        // Create the color buffer
        let colorBufferDescriptor = MTLTextureDescriptor()
        colorBufferDescriptor.textureType = .type2D
        colorBufferDescriptor.pixelFormat = .bgra8Unorm
        colorBufferDescriptor.width = width
        colorBufferDescriptor.height = height
        colorBufferDescriptor.depth = 1
        colorBufferDescriptor.mipmapLevelCount = 1
        colorBufferDescriptor.sampleCount = 1
        colorBufferDescriptor.arrayLength = 1
        colorBufferDescriptor.usage = MTLTextureUsage([.renderTarget, .shaderRead])
        colorBuffer = device.makeTexture(descriptor: colorBufferDescriptor)!

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 1
        colorBufferSampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        // Create the depth buffer
        let depthBufferDescriptor = MTLTextureDescriptor()
        depthBufferDescriptor.textureType = .type2D
        depthBufferDescriptor.pixelFormat = .depth32Float
        depthBufferDescriptor.width = width
        depthBufferDescriptor.height = height
        depthBufferDescriptor.depth = 1
        depthBufferDescriptor.mipmapLevelCount = 1
        depthBufferDescriptor.sampleCount = 1
        depthBufferDescriptor.arrayLength = 1
        depthBufferDescriptor.usage = MTLTextureUsage([.renderTarget, .shaderRead])
        depthBuffer = device.makeTexture(descriptor: depthBufferDescriptor)!
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = colorBuffer
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        renderPassDescriptor.depthAttachment.texture = depthBuffer
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
    }
    
}
