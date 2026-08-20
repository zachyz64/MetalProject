//
//  RenderScene.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/9/26.
//

import Foundation
internal import Combine
import GameController

class GameScene: ObservableObject {
    
    @Published var player: Camera
    @Published var ground: Actor
    @Published var actors: [Actor]
    @Published var mouse: Billboard
    @Published var sun: Light
    @Published var spotlight: Light
    @Published var pointlights: [BrightBillboard]
    @Published var lastKey: String
    @Published var mouseDelta: Point2D
    
    init() {
        lastKey = ""
        mouseDelta = Point2D(x: 0, y: 0)
        
        player = Camera(position: [-6.0, 6.0, 2.0],
                        eulers: [0.0, 0.0, 0.0])
        
        ground = Actor(TransformComponent(position: [0.0, 0.0, 0.0],
                                          eulers: [90.0, 0.0, 0.0],
                                          scale: [0.33, 0.33, 0.33]))
        
        actors = [
            Actor(TransformComponent(position: [0.0, 0.0, 0.0],
                                     eulers: [90.0, 0.0, 0.0],
                                     scale: [1.0, 1.0, 1.0])),
        ]

        mouse = Billboard(TransformComponent(position: [0.0, 0.0, 3.0],
                                             eulers: [0.0, 0.0, 0.0],
                                             scale: [1.0, 1.0, 1.0]))
        
        sun = Light(color: [1.0, 1.0, 1.0])
        spotlight = Light(color: [1.0, 0.0, 0.0])
        
        pointlights = [BrightBillboard]()
        pointlights.append(BrightBillboard(position: [0.0, 0.0, 1.0],
                                           color: [0.0, 1.0, 1.0],
                                           rotationCenter: [0.0, 0.0, 1.0],
                                           pathRadius: 2.0,
                                           pathPhi:  60.0,
                                           angularVelocity: 1.0))
        
        pointlights.append(BrightBillboard(position: [0.0, 0.0, 1.0],
                                           color: [0.0, 0.0, 1.0],
                                           rotationCenter: [0.0, 0.0, 1.0],
                                           pathRadius: 3.0,
                                           pathPhi:  0.0,
                                           angularVelocity: 2.0))
        
        sun.declareDirectional(eulers: [0.0, 135.0, 45.0])
        sun.update()
        
        spotlight.declareSpotlight(position: [-2.0, 0.0, 3.0],
                                   eulers: [0.0, 0.0, 180.0])
    }
    
    func update() {
        if ProcessInfo.processInfo.isiOSAppOnMac {
            var movement: simd_float3 = [0.0, 0.0, 0.0]
            if InputController.controller.keysPressed.contains(.keyW) {
                movement.x += 0.05
            }
            if InputController.controller.keysPressed.contains(.keyA) {
                movement.y += 0.05
            }
            if InputController.controller.keysPressed.contains(.keyS) {
                movement.x -= 0.05
            }
            if InputController.controller.keysPressed.contains(.keyD) {
                movement.y -= 0.05
            }
            if InputController.controller.keysPressed.contains(.keyQ) {
                movement.z -= 0.05
            }
            if InputController.controller.keysPressed.contains(.keyE) {
                movement.z += 0.05
            }
            
            player.move(amount: movement)
            
            let newMouseDelta: Point2D = InputController.controller.mouseDelta
            if abs(mouseDelta.x - newMouseDelta.x) + abs(mouseDelta.y - newMouseDelta.y) > 0.0001 {
                mouseDelta = newMouseDelta
                spinPlayer(angles: mouseDelta)
            }
        }
        
        player.update()
        
        for actor in actors {
            actor.transform.eulers.z += 1.0
            if actor.transform.eulers.z > 360.0 {
                actor.transform.eulers.z -= 360.0
            }
            actor.update()
        }
        
        mouse.update(viewerPosition: player.position)
        
        ground.update()
        
        spotlight.update()
        
        for light in pointlights {
            light.update(viewerPosition: player.position)
        }
        
        updateView()
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func spinPlayer(offset: CGSize) {
        let dTheta: Float = Float(offset.width)
        let dPhi: Float = Float(offset.height)
        
        player.eulers.z -= 0.01 * dTheta
        player.eulers.y += 0.01 * dPhi
        
        if player.eulers.z < 0 {
            player.eulers.z += 360
        } else if player.eulers.z > 360 {
            player.eulers.z -= 360
        }
        
        if player.eulers.y < 1 {
            player.eulers.y = 1
        } else if player.eulers.y > 179 {
            player.eulers.y = 179
        }
    }
    
    func spinPlayer(angles: Point2D) {
        let dTheta: Float = angles.x
        let dPhi: Float = angles.y
        
        player.eulers.z -= 0.05 * dTheta
        player.eulers.y += 0.05 * dPhi
        
        if player.eulers.z < 0 {
            player.eulers.z += 360
        } else if player.eulers.z > 360 {
            player.eulers.z -= 360
        }
        
        if player.eulers.y < -89 {
            player.eulers.y = -89
        } else if player.eulers.y > 89 {
            player.eulers.y = 89
        }
    }
    
    func rotatePlayer(offset: CGSize) {
        let rightAmount: Float = Float(offset.width) / 1000.0
        let upAmount: Float = Float(offset.height) / 1000.0
        player.rotateCamera(rightAmount: rightAmount, upAmount: upAmount)
    }
}
