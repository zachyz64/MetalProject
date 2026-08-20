//
//  renderer.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/1/26.
//

import MetalKit
import Foundation

class Renderer: NSObject, MTKViewDelegate {
    var parent: ContentView
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    
    let materialLoader: MTKTextureLoader
    let meshAllocator: MTKMeshBufferAllocator
    
    var pipelines: Dictionary<Int32, MTLRenderPipelineState>
    
    let depthStencilState: MTLDepthStencilState
    
    var scene: GameScene
    
    let sampler: MTLSamplerState
    
    let model: Model
    let floor: Model
    let mouse: Model
    let light: Model
    
    let pbrMaterial: PBRMaterial
    let cubemap: Cubemap
    
    let customRenderPass: RenderPass
    let playerRenderPass: RenderPass
    let screenQuad: ScreenQuad
    
    init(_ parent: ContentView, _ scene: GameScene) {
        
        self.parent = parent
        self.scene = scene
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        self.materialLoader = MTKTextureLoader(device: device)
        
        self.meshAllocator = MTKMeshBufferAllocator(device: device)

        // Set up the vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        // Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<simd_float3>.stride
        // Texture Coordinate
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<simd_float2>.stride
        // Normal
        vertexDescriptor.attributes[2].format = .float3
        vertexDescriptor.attributes[2].offset = offset
        vertexDescriptor.attributes[2].bufferIndex = 0
        offset += MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.layouts[0].stride = offset
        
        // Set up vertex descriptor for screenTexture
        let simpleVertexDescriptor = MTLVertexDescriptor()
        offset = 0
        // Position
        simpleVertexDescriptor.attributes[0].format = .float2
        simpleVertexDescriptor.attributes[0].offset = offset
        simpleVertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<simd_float2>.stride
        simpleVertexDescriptor.layouts[0].stride = offset
        
        self.model = Model(device: device,
                           allocator: meshAllocator,
                           vertexDescriptor: vertexDescriptor,
                           textureLoader: materialLoader,
                           filename: "Yuzuha",
                           flipTexture: true)
        
        self.floor = Model(device: device,
                           allocator: meshAllocator,
                           vertexDescriptor: vertexDescriptor,
                           textureLoader: materialLoader,
                           filename: "floor",
                           flipTexture: true)
        
        self.mouse = Model(device: device,
                           allocator: meshAllocator,
                           vertexDescriptor: vertexDescriptor,
                           textureLoader: materialLoader,
                           filename: "mouse",
                           flipTexture: false)
        
        self.light = Model(device: device,
                           allocator: meshAllocator,
                           vertexDescriptor: vertexDescriptor,
                           textureLoader: materialLoader,
                           filename: "light",
                           flipTexture: false)
        
        // PBR Material
        pbrMaterial = PBRMaterial(device: device, allocator: materialLoader, layerCount: 9, queue: commandQueue,
                                  format: .bgra8Unorm)
        pbrMaterial.consume(filename: "Stone_1K_AO",
                            filenameExtension: "jpg", layer: 7)
        pbrMaterial.consume(filename: "Stone_1K_BaseColor",
                            filenameExtension: "jpg", layer: 0)
        pbrMaterial.consume(filename: "Stone_1K_Bump",
                            filenameExtension: "jpg", layer: 5)
        pbrMaterial.consume(filename: "Stone_1K_Cavity",
                            filenameExtension: "jpg", layer: 8)
        pbrMaterial.consume(filename: "Stone_1K_Displacement",
                            filenameExtension: "jpg", layer: 4)
        pbrMaterial.consume(filename: "Stone_1K_Gloss",
                            filenameExtension: "jpg", layer: 6)
        pbrMaterial.consume(filename: "Stone_1K_Normal",
                            filenameExtension: "jpg", layer: 1)
        pbrMaterial.consume(filename: "Stone_1K_Roughness",
                            filenameExtension: "jpg", layer: 3)
        pbrMaterial.consume(filename: "Stone_1K_Specular",
                            filenameExtension: "jpg", layer: 2)
        pbrMaterial.finalize()
        
        // Cubemap Materials
        let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: true,
            .origin: MTKTextureLoader.Origin.flippedVertically
        ]
        
        cubemap = Cubemap(device: device, allocator: materialLoader, queue: commandQueue, format: .bgra8Unorm)
        cubemap.consume(filename: "front", filenameExtension: "jpg", layer: 0)
        cubemap.consume(filename: "back", filenameExtension: "jpg", layer: 1)
        cubemap.consume(filename: "left", filenameExtension: "jpg", layer: 2)
        cubemap.consume(filename: "right", filenameExtension: "jpg", layer: 3)
        cubemap.consume(filename: "top", filenameExtension: "jpg", layer: 4)
        cubemap.consume(filename: "bottom", filenameExtension: "jpg", layer: 5)
        cubemap.finalize()
        
        let library = device.makeDefaultLibrary()!
        
        pipelines = [:]
        pipelines[PIPELINE_TYPE_LIT] = PipelineBuilder.BuildPipeline(device: device,
                                                                     library: library,
                                                                     vs: "vertexLit",
                                                                     fs: "fragmentLit",
                                                                     vertexDescriptor: vertexDescriptor,
                                                                     depthEnabled: true)
        
        pipelines[PIPELINE_TYPE_EMISSIVE] = PipelineBuilder.BuildPipeline(device: device,
                                                                          library: library,
                                                                          vs: "vertexUnlit",
                                                                          fs: "fragmentUnlit",
                                                                          vertexDescriptor: vertexDescriptor,
                                                                          depthEnabled: true)
        
        pipelines[PIPELINE_TYPE_PBR] = PipelineBuilder.BuildPipeline(device: device,
                                                                     library: library,
                                                                     vs: "vertexPBR",
                                                                     fs: "fragmentPBR",
                                                                     vertexDescriptor: vertexDescriptor,
                                                                     depthEnabled: true)
        
        pipelines[PIPELINE_TYPE_POST] = PipelineBuilder.BuildPipeline(device: device,
                                                                      library: library,
                                                                      vs: "vertexShaderPost",
                                                                      fs: "fragmentShaderPost",
                                                                      vertexDescriptor: vertexDescriptor,
                                                                      depthEnabled: true)
        
        pipelines[PIPELINE_TYPE_SKY] = PipelineBuilder.BuildPipeline(device: device,
                                                                     library: library,
                                                                     vs: "vertexShaderSky",
                                                                     fs: "fragmentShaderSky",
                                                                     vertexDescriptor: vertexDescriptor,
                                                                     depthEnabled: true)
        
        // Set up depthStencilDescriptor
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        
        // Set up sampler
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.maxAnisotropy = 8
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        customRenderPass = RenderPass(device: device, width: 800, height: 600)
        playerRenderPass = RenderPass(device: device, width: 800, height: 600)
        screenQuad = ScreenQuad(device: device)
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        scene.update()
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // Draw to a texture
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: customRenderPass.renderPassDescriptor)
        
        drawSky(renderEncoder: renderEncoder)
        
        renderEncoder?.setFrontFacing(.counterClockwise)
        drawLitObjects(renderEncoder: renderEncoder)
        
        drawUnlitObjects(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
        
        // Draw post process stuff
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let postprocessRenderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        drawPostProcess(renderEncoder: postprocessRenderEncoder)
        
        postprocessRenderEncoder?.endEncoding()
        
        // Finish
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func drawLitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_LIT]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)

        sendCameraData(renderEncoder)

        sendLightData(renderEncoder)
        
        // Render floor
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_PBR]!)
        renderEncoder?.setFragmentSamplerState(pbrMaterial.sampler, index: 0)
        renderEncoder?.setFragmentTexture(pbrMaterial.texture, index: 0)
        renderEncoder?.setCullMode(.none)
        drawPBR(renderEncoder: renderEncoder, model: floor, modelTransform: &(scene.ground.model))
        
        // Render models
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_LIT]!)
        renderEncoder?.setFragmentSamplerState(sampler, index: 0)
        renderEncoder?.setCullMode(.back)
        for actor in scene.actors {
            draw(renderEncoder: renderEncoder, model: model, modelTransform: &(actor.model))
        }
    
        // Render mouse billboard
        renderEncoder?.setCullMode(.none)
        draw(renderEncoder: renderEncoder, model: mouse, modelTransform: &(scene.mouse.model))
    }
    
    func drawUnlitObjects(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_EMISSIVE]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)
        
        renderEncoder?.setCullMode(.none)
        
        sendCameraData(renderEncoder)
        
        renderEncoder?.setFragmentSamplerState(sampler, index: 0)

        for pl in scene.pointlights {
            renderEncoder?.setFragmentBytes(&(pl.color),
                                            length: MemoryLayout<simd_float3>.stride,
                                            index: 0)
            
            renderEncoder?.setVertexBytes(&(pl.model),
                                          length: MemoryLayout<simd_float4x4>.stride,
                                          index: 1)
            
            for mesh in light.meshes {
                let vertexBuffer = mesh.mesh.vertexBuffers[0]
                renderEncoder?.setVertexBuffer(vertexBuffer.buffer,
                                               offset: vertexBuffer.offset,
                                               index: 0)
                
                for (submesh, material) in zip(mesh.mesh.submeshes, mesh.materials) {
                    // Bind texture
                    renderEncoder?.setFragmentTexture(material.texture, index: 0)
                    renderEncoder?.setFragmentSamplerState(sampler, index: 0)
                    // Draw
                    renderEncoder?.drawIndexedPrimitives(type: .triangle,
                                                         indexCount: submesh.indexCount,
                                                         indexType: submesh.indexType,
                                                         indexBuffer: submesh.indexBuffer.buffer,
                                                         indexBufferOffset: 0)
                }
            }
        }
    }
    
    func drawPostProcess(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_POST]!)
        renderEncoder?.setFragmentTexture(customRenderPass.colorBuffer, index: 0)
        renderEncoder?.setFragmentSamplerState(customRenderPass.colorBufferSampler, index: 0)
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer, offset: 0, index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle,
                                      vertexStart: 0,
                                      vertexCount: screenQuad.vertexCount)
    }
    
    func drawSky(renderEncoder: MTLRenderCommandEncoder?) {
        
        renderEncoder?.setRenderPipelineState(pipelines[PIPELINE_TYPE_SKY]!)
        renderEncoder?.setDepthStencilState(customRenderPass.depthStencilState)
        
        renderEncoder?.setVertexBuffer(screenQuad.vertexBuffer,
                                       offset: 0,
                                       index: 0)
        
        var cameraFrame = CameraFrame(forward: scene.player.forward,
                                      right: scene.player.right,
                                      up: scene.player.up,
                                      aspect: 800.0 / 600.0)
        
        renderEncoder?.setVertexBytes(&cameraFrame,
                                      length: MemoryLayout<CameraFrame>.stride,
                                      index: 1)
        
        renderEncoder?.setFragmentTexture(cubemap.texture, index: 0)
        renderEncoder?.setFragmentSamplerState(cubemap.sampler, index: 0)
        renderEncoder?.setCullMode(.none)
        
        renderEncoder?.drawPrimitives(type: .triangle,
                                      vertexStart: 0,
                                      vertexCount: 6)
    }
    
    func sendCameraData(_ renderEncoder: MTLRenderCommandEncoder?) {
        
        // Create Camera data
        var cameraData: CameraParameters = CameraParameters()
        cameraData.view = scene.player.view
        cameraData.projection = scene.player.projection
        cameraData.position = scene.player.position
        renderEncoder?.setVertexBytes(&cameraData,
                                      length: MemoryLayout<CameraParameters>.stride,
                                      index: 2)
    }
    
    func sendLightData(_ renderEncoder: MTLRenderCommandEncoder?) {
        
        // Create directional light data
        var sun: DirectionalLight = DirectionalLight()
        sun.color = scene.sun.color
        sun.forward = scene.sun.forward!
        renderEncoder?.setFragmentBytes(&sun,
                                        length: MemoryLayout<DirectionalLight>.stride,
                                        index: 0)
        // Create spotlight data
        var spotlight: Spotlight = Spotlight()
        spotlight.color = scene.spotlight.color
        spotlight.forward = scene.spotlight.forward!
        spotlight.position = scene.spotlight.position!
        renderEncoder?.setFragmentBytes(&spotlight,
                                        length: MemoryLayout<Spotlight>.stride,
                                        index: 1)
        
        // Create pointlight data
        var pointlights: [Pointlight] = [Pointlight]()
        for pl in scene.pointlights {
            var pointlight = Pointlight()
            pointlight.color = pl.color
            pointlight.position = pl.position
            pointlights.append(pointlight)
        }
        renderEncoder?.setFragmentBytes(&pointlights,
                                        length: scene.pointlights.count * MemoryLayout<Pointlight>.stride,
                                        index: 2)
        
        var fragUBO = FragmentData()
        fragUBO.lightCount = UInt32(scene.pointlights.count)
        renderEncoder?.setFragmentBytes(&fragUBO,
                                        length: MemoryLayout<FragmentData>.stride,
                                        index: 3)
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?, model: Model, modelTransform: UnsafeMutablePointer<simd_float4x4>) {
        
        renderEncoder?.setVertexBytes(modelTransform,
                                      length: MemoryLayout<simd_float4x4>.stride,
                                      index: 1)
        for mesh in model.meshes {
            let vertexBuffer = mesh.mesh.vertexBuffers[0]
            renderEncoder?.setVertexBuffer(vertexBuffer.buffer,
                                           offset: vertexBuffer.offset,
                                           index: 0)
            
            for (submesh, material) in zip(mesh.mesh.submeshes, mesh.materials) {
                // Bind texture
                renderEncoder?.setFragmentTexture(material.texture, index: 0)
                renderEncoder?.setFragmentSamplerState(sampler, index: 0)
                // Draw
                renderEncoder?.drawIndexedPrimitives(type: .triangle,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: 0)
            }
        }
    }
    
    func drawPBR(renderEncoder: MTLRenderCommandEncoder?, model: Model, modelTransform: UnsafeMutablePointer<simd_float4x4>) {
        
        renderEncoder?.setVertexBytes(modelTransform,
                                      length: MemoryLayout<simd_float4x4>.stride,
                                      index: 1)
        
        for mesh in model.meshes {
            let vertexBuffer = mesh.mesh.vertexBuffers[0]
            renderEncoder?.setVertexBuffer(vertexBuffer.buffer,
                                           offset: vertexBuffer.offset,
                                           index: 0)
            
            for (submesh, material) in zip(mesh.mesh.submeshes, mesh.materials) {
                // Draw
                renderEncoder?.drawIndexedPrimitives(type: .triangle,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: submesh.indexBuffer.buffer,
                                                     indexBufferOffset: 0)
            }
        }
        
    }
}
