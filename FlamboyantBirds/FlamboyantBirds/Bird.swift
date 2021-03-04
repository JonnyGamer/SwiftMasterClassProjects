//
//  Bird.swift
//  FlamboyantBirds
//
//  Created by Jonathan Pappas on 3/3/21.
//

import Foundation
import SpriteKit


class Bird : SKSpriteNode {
    
    
    static func Make() -> Bird {
        let bird = Bird(imageNamed: "Blue 1")
        bird.makeBird()
        return bird
    }
    
    
    func makeBird() {
        makeAnimation()
        runAnimationForever()
    }
    
    
    var birdAnimationAction: ((Double) -> SKAction)!
    
    func makeAnimation() {
        
        
        let birdTextures = [
            SKTexture(imageNamed: "Blue 1"),
            SKTexture(imageNamed: "Blue 2"),
            SKTexture(imageNamed: "Blue 3")
        ]
        
        birdAnimationAction = {
            return SKAction.animate(with: birdTextures, timePerFrame: $0, resize: true, restore: true)
        }
    }
    
    
    func runAnimationForever() {
        run(.repeatForever(birdAnimationAction(0.08)))
    }
    
    
    
}




