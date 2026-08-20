//
//  AppView.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import SwiftUI

struct appView: View {
    
    @FocusState private var isFocused: Bool
    @EnvironmentObject var gameScene: GameScene
    
    var body: some View {
        VStack {
            Text("Model Viewer")
            
            ContentView()
                .frame(width: 800, height: 600)
                .gesture(
                    DragGesture()
                        .onChanged({ gesture in
                            gameScene.rotatePlayer(offset: gesture.translation)
                        })
                )
            Text("Debug Info")
        }
        HStack {
            VStack(alignment: .center) {
                Text("Camera")
                HStack {
                    Text("Position")
                    VStack(alignment: .trailing) {
                        Text("\(gameScene.player.position.x, specifier: "%.2f")")
                        Text("\(gameScene.player.position.y, specifier: "%.2f")")
                        Text("\(gameScene.player.position.z, specifier: "%.2f")")
                    }
                    Text("Eulers")
                    VStack(alignment: .trailing) {
                        Text("\(gameScene.player.eulers.x, specifier: "%.2f")")
                        Text("\(gameScene.player.eulers.y, specifier: "%.2f")")
                        Text("\(gameScene.player.eulers.z, specifier: "%.2f")")
                    }
                }
            }
            VStack(alignment: .center) {
                Text("Yuzuha")
                HStack {
                    Text("Eulers")
                    VStack(alignment: .trailing) {
                        Text("\(gameScene.actors[0].transform.eulers.x, specifier: "%.2f")")
                        Text("\(gameScene.actors[0].transform.eulers.y, specifier: "%.2f")")
                        Text("\(gameScene.actors[0].transform.eulers.z, specifier: "%.2f")")
                    }
                }
            }
        }
        .focusable()
        .focused($isFocused)
        .onAppear(perform: { isFocused = true })
        .onKeyPress(action: { _ in return .handled })
    }
}

struct appView_Previews: PreviewProvider {
    static var previews: some View {
        appView().environmentObject(GameScene())
    }
}
