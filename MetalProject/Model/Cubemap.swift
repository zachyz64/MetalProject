//
//  Cubemap.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/22/26.
//

import MetalKit

class Cubemap {
    
    var texture: MTLTexture
    var sampler:  MTLSamplerState
    var commandBuffer: MTLCommandBuffer
    var blitCommandEncoder: MTLBlitCommandEncoder
    var tempTextures: [Material]
    var device: MTLDevice
    var allocator: MTKTextureLoader
    
    let options: [MTKTextureLoader.Option: Any]
    
    init(device: MTLDevice, allocator: MTKTextureLoader, queue: MTLCommandQueue, format: MTLPixelFormat) {
        
        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = .typeCube
        textureDescriptor.pixelFormat = format
        textureDescriptor.width = 2048
        textureDescriptor.height = 2048
        textureDescriptor.depth = 1
        textureDescriptor.mipmapLevelCount = 1
        textureDescriptor.sampleCount = 1
        textureDescriptor.arrayLength = 1
        textureDescriptor.allowGPUOptimizedContents = true
        textureDescriptor.usage = .shaderRead
        
        texture = device.makeTexture(descriptor: textureDescriptor)!
        
        commandBuffer = queue.makeCommandBuffer()!
        blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()!
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        tempTextures = []
        self.device = device
        self.allocator = allocator
        
        options = [
            .SRGB: false,
            .generateMipmaps: true,
            .origin: MTKTextureLoader.Origin.flippedVertically
        ]
    }
    
    func consume(filename: String, filenameExtension: String, layer: Int32) {
        
        let newMaterial = Material(device: device,
                                   allocator: allocator,
                                   filename: filename,
                                   filenameExtension: filenameExtension,
                                   options: options)
        
        blitCommandEncoder.copy(from: newMaterial.texture!, sourceSlice: 0, sourceLevel: 0,
                                to: texture, destinationSlice: Int(layer), destinationLevel: 0,
                                sliceCount: 1, levelCount: 1)
        
        tempTextures.append(newMaterial)
    }
    
    func finalize() {
        blitCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
