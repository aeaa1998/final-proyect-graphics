//
//  Gesture.swift
//  RayBreak
//
//  Created by Augusto Alonso on 11/22/20.
//

import Foundation
import UIKit
class Gesture: UISwipeGestureRecognizer {
    var touchStart: CGPoint?
    var startTime : TimeInterval?
    let minSpeed:CGFloat = 1000
    let maxSpeed:CGFloat = 5000
    let minDistance:CGFloat = 25
    let minDuration:TimeInterval = 0.1
    var onTouchEnded: OnTouchEnded?
    typealias OnTouchEnded = (Int, Int) -> Void
    var onTouchMoved: OnTouchMoved?
    typealias OnTouchMoved = (CGFloat, CGFloat) -> Void

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touchStart = touches.first?.location(in: self.view)
        startTime = touches.first?.timestamp
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let onTouchMoved = onTouchMoved{
            guard let touchStart = self.touchStart else {
                return
            }
            
            guard let startTime = self.startTime else {
                return
            }
            guard let location = touches.first?.location(in: self.view) else {
                return
            }
            guard let time = touches.first?.timestamp else {
                return
            }
            var dx = location.x - touchStart.x
            var dy = location.y - touchStart.y
            // Distance of the gesture
            let distance = sqrt(dx*dx+dy*dy)
            if distance >= minDistance {
                // Duration of the gesture
                let deltaTime = time - startTime
                if deltaTime > minDuration {
                    // Speed of the gesture
                    let speed = distance / CGFloat(deltaTime)
                    if speed >= minSpeed && speed <= maxSpeed {
                        // Normalize by distance to obtain unit vector
                        dx /= distance
                        dy /= distance
                        // Swipe detected
                        print("Swipe detected with speed = \(speed) and direction (\(dx), \(dy)")
                    }
                }
            }
            // Reset variables
            onTouchMoved(dx,dy)
            self.touchStart = .init(x: location.x, y: location.y)
            self.startTime = touches.first?.timestamp
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchStart = self.touchStart else {
            return
        }
        guard let startTime = self.startTime else {
            return
        }
        guard let location = touches.first?.location(in: self.view) else {
            return
        }
        guard let time = touches.first?.timestamp else {
            return
        }
        var dx = location.x - touchStart.x
        var dy = location.y - touchStart.y
        // Distance of the gesture
        let distance = sqrt(dx*dx+dy*dy)
        if distance >= minDistance {
            // Duration of the gesture
            let deltaTime = time - startTime
            if deltaTime > minDuration {
                // Speed of the gesture
                let speed = distance / CGFloat(deltaTime)
                if speed >= minSpeed && speed <= maxSpeed {
                    // Normalize by distance to obtain unit vector
                    dx /= distance
                    dy /= distance
                    // Swipe detected
                    print("Swipe detected with speed = \(speed) and direction (\(dx), \(dy)")
                }
            }
        }
        // Reset variables
        self.touchStart = nil
        self.startTime = nil
    }
}


