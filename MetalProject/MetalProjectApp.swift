//
//  MetalProjectApp.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/1/26.
//

import SwiftUI

@main
struct MetalProjectApp: App {
    
    @StateObject private var gameScene = GameScene()
    
    var body: some Scene {
        WindowGroup {
            appView().environmentObject(gameScene)
        }
    }
}
