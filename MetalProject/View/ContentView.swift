//
//  ContentView.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/1/26.
//

import SwiftUI
import MetalKit
 
struct ContentView: UIViewRepresentable {
    
    @EnvironmentObject var gameScene: GameScene
    
    func makeCoordinator() -> Renderer {
        Renderer(self, gameScene)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) ->  MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = true
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
}

#Preview {
    ContentView()
}
