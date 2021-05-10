//
//  GameScene.swift
//  SpriteKitPlatformer
//
//  Created by Jonathan Pappas on 5/8/21.
//

import SpriteKit
import GameplayKit

class Player {
    static var jumps: Int = 0
    static var maxJumps: Int = 1
    static func canJump() -> Bool {
        if jumps == 0, contacts == 0 { jumps += 1 }
        return jumps < maxJumps
    }
    static func jump() {
        jumps += 1
        print(jumps)
    }
    
    static var contacts: Int = 0
    static func contactBegan(resetJumps: Bool = true) {
        contacts += 1
        if resetJumps {
            jumps = 0
        }
    }
    static func contactEnded() { contacts -= 1 }
    
    static var previousVelocity: CGVector = .zero
    static var velocity: CGVector = .zero {
        willSet(to) {
            previousVelocity = velocity
        }
    }
    static var increasingXVelocity: Bool { return previousVelocity.dx < velocity.dx }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode.init(imageNamed: "Inky")
    var magicCamera: SKCameraNode!
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .white
        
        if let foo = SKScene.init(fileNamed: "GameScene") {
            for i in foo.children {
                i.removeFromParent()
                addChild(i)
            }
        }
        
        addChild(player)
        player.physicsBody = .init(texture: player.texture!, size: player.size)
        player.setScale(0.5)
        player.physicsBody = .init(circleOfRadius: player.size.width/2)
        player.physicsBody?.restitution = 0
        player.physicsBody?.contactTestBitMask = .max
        player.physicsBody?.linearDamping = 1
        player.physicsBody?.friction = 0//0.5
        player.physicsBody?.allowsRotation = false
        
        magicCamera = SKCameraNode()
        camera = magicCamera
        addChild(magicCamera)
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        Player.velocity = player.physicsBody!.velocity
        if Player.velocity.dy < -600 { player.physicsBody?.velocity.dy = -600 }
        
        if moving.up, Player.canJump() {
            player.physicsBody?.velocity.dy = 1500//1000
            Player.jump()
            moving.up = false
        }
        
        if moving.right, moving.left {
            player.physicsBody?.velocity.dx = 0
        } else if moving.right {
            player.physicsBody?.velocity.dx = 600
            //player.position.x += 10
        } else if moving.left {
            player.physicsBody?.velocity.dx = -600
            //player.position.x -= 10
        } else if Player.contacts == 0 {
            player.physicsBody?.velocity.dx = 0
        } else if !Player.increasingXVelocity {
            player.physicsBody?.velocity.dx = 0
        } else {
            print("Increasing?")
        }
            
        magicCamera.run(.move(to: .init(x: player.position.x + (Player.velocity.dx*1.5), y: player.position.y + (Player.velocity.dy*1.5)), duration: 1))
        
    }
    
    var moving: (up: Bool, down: Bool, left: Bool, right: Bool) = (false, false, false, false)
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 126 {
            moving.up = true
        } else if event.keyCode == 123 {
            moving.left = true
        } else if event.keyCode == 125 {
            moving.down = true
        } else if event.keyCode == 124 {
            moving.right = true
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 126 {
            moving.up = false
        } else if event.keyCode == 123 {
            moving.left = false
        } else if event.keyCode == 125 {
            moving.down = false
        } else if event.keyCode == 124 {
            moving.right = false
        }
    }
    //-60.103454775
    
    override func didFinishUpdate() {
        //print(player.frame.midY)
    }
    
    // -1037.6514892578125/17.264423370361328
    func didBegin(_ contact: SKPhysicsContact) {
        print("Begin")
        
        // Hit somthing with less steep slope than a wall |
        if contact.contactNormal.dy > 0.001 {
            if contact.bodyA.node === player { Player.contactBegan() }
            if contact.bodyB.node === player { Player.contactBegan() }
        } else {
            // Dissallows Cieling Hops and Wall Jumping
            if contact.bodyA.node === player { Player.contactBegan(resetJumps: false) }
            if contact.bodyB.node === player { Player.contactBegan(resetJumps: false) }
        }
    }
    
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        print("End")
        if contact.bodyA.node === player { Player.contactEnded() }
        if contact.bodyB.node === player { Player.contactEnded() }
    }
    

}