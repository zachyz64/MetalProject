//
//  Controller.swift
//  MetalProject
//
//  Created by Zach Zaborowski on 7/15/26.
//

import GameController

struct Point2D {
    var x: Float
    var y: Float
}

class InputController {
    
    static let controller: InputController = InputController()
    
    var keysPressed: Set<GCKeyCode> = []
    var mouseDown: Bool = false
    var mouseDelta: Point2D = Point2D(x: 0, y: 0)
    
    init() {
        
        let center = NotificationCenter.default
        
        center.addObserver(forName: .GCKeyboardDidConnect,
                           object: nil,
                           queue: nil) {
            notification in
                let keyboard = notification.object as? GCKeyboard
            
            keyboard?.keyboardInput?.keyChangedHandler = {
                _, _, keyCode, pressed in
                    if pressed {
                        self.keysPressed.insert(keyCode)
                    } else {
                        self.keysPressed.remove(keyCode)
                    }
            }
        }
        
        center.addObserver(forName: .GCMouseDidConnect, object: nil,
                           queue: nil) {
            notification in
                let mouse = notification.object as? GCMouse
    
            mouse?.mouseInput?.leftButton.pressedChangedHandler = {
                _, _, pressed in
                    self.mouseDown = pressed
            }
            
            mouse?.mouseInput?.mouseMovedHandler = {
                _, deltaX, deltaY in
                    self.mouseDelta = Point2D(x: deltaX, y: deltaY)
            }
        }
        
    }
}
