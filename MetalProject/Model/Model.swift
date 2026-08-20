//
//  Mesh.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/10/26.
//

import MetalKit

struct Material {
    var texture: MTLTexture?
    
    init(mdlMaterial: MDLMaterial?, textureLoader: MTKTextureLoader, options: [MTKTextureLoader.Option: Any]) {
        self.texture = loadTexture(.baseColor,
                                   mdlMaterial: mdlMaterial,
                                   textureLoader: textureLoader,
                                   options: options)
    }
    
    init(device: MTLDevice, allocator: MTKTextureLoader,
         filename: String, filenameExtension: String,
         options: [MTKTextureLoader.Option: Any] = [.SRGB: false, .generateMipmaps: true]) {
        
        guard let materialURL = Bundle.main.url(forResource: filename, withExtension: filenameExtension) else {
            fatalError()
        }
        
        do {
            texture = try allocator.newTexture(URL: materialURL, options: options)
        } catch {
            fatalError("Couldn't load material \(filename)")
        }
    }
    
    func loadTexture(_ semantic: MDLMaterialSemantic,
                     mdlMaterial: MDLMaterial?,
                     textureLoader: MTKTextureLoader,
                     options: [MTKTextureLoader.Option: Any]) -> MTLTexture? {
        
        guard let materialProperty = mdlMaterial?.property(with: semantic) else { return nil }
        
        // Extract name from path
        let start = materialProperty.stringValue?.index(after: (materialProperty.stringValue?.firstIndex(of: "/"))!)
        let end = materialProperty.stringValue?.firstIndex(of: ".")
        let range = start!..<end!
        let name = String((materialProperty.stringValue?[range])!)
        var url = Bundle.main.url(forResource: name, withExtension: "png")
        if url == nil {
            url = Bundle.main.url(forResource: name, withExtension: "jpg")
        }

        return try? textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: Bundle.main, options: options)
    }
}

class Mesh {
    var mesh: MTKMesh
    var modelIOMesh: MDLMesh
    var materials: [Material]
    
    init(mesh: MTKMesh, modelIOMesh: MDLMesh, materials: [Material]) {
        self.mesh = mesh
        self.modelIOMesh = modelIOMesh
        self.materials = materials
    }
}

class Model {
    var meshes: [Mesh] = [Mesh]()

    init(device: MTLDevice, allocator: MTKMeshBufferAllocator, vertexDescriptor: MTLVertexDescriptor, textureLoader: MTKTextureLoader, filename: String, flipTexture: Bool = true) {
        
        guard let meshURL = Bundle.main.url(forResource: filename, withExtension: "obj") else {
            fatalError("Couldn't find obj file")
        }
        
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (meshDescriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (meshDescriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(
            url: meshURL,
            vertexDescriptor: meshDescriptor,
            bufferAllocator: bufferAllocator
        )
        
        // Load data for textures
        asset.loadTextures()
        
        guard let (mdlMeshes, mtkMeshes) = try? MTKMesh.newMeshes(asset: asset, device: device) else {
            fatalError("Failed to load meshes")
        }

        self.meshes.reserveCapacity(mdlMeshes.count)
        
        var options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .generateMipmaps: true
        ]
        if flipTexture {
            options[.origin] = MTKTextureLoader.Origin.flippedVertically
        }
        
        for (mdlMesh, mtkMesh) in zip(mdlMeshes, mtkMeshes) {
            var materials = [Material]()

            for mdlSubmesh in mdlMesh.submeshes as! [MDLSubmesh] {
                let material = Material(mdlMaterial: mdlSubmesh.material, textureLoader: textureLoader, options: options)
                materials.append(material)
            }
            let mesh = Mesh(mesh: mtkMesh, modelIOMesh: mdlMesh, materials: materials)
            self.meshes.append(mesh)
        }
    }
}
