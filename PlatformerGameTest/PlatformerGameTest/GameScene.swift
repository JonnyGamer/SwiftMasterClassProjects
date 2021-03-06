//
//  GameScene.swift
//  PlatformerGameTest
//
//  Created by Jonathan Pappas on 4/12/21.
//

import SpriteKit
import GameplayKit
//
//class GameScene: SKScene {
//
//}
var currentView: CGRect = .zero
var paddedView: CGRect = .zero

extension CGRect {
    func padding(_ n: Int) -> CGRect {
        return CGRect.init(x: self.minX - (n.cg * u.cg), y: self.minY - (n.cg * u.cg), width: self.width + (n.cg * 2 * u.cg), height: self.height + (n.cg * 2 * u.cg))
    }
    func someWhatOffScreen() -> CGRect {
        return padding(4)
    }
}

extension Scene {
    func add(_ this: BasicSprite) {
        //sprites.insert(this)
        if let s = this as? MovableSprite {
            movableSprites.insert(s)
            addChild(s.skNode)
            if let q = this as? BasicSprite & SKActionable {
                addChild(q.actionSprite)
                q.actionSprite.position = CGPoint(x: s.position.x, y: s.position.y)
            }
            if !s.contactOn.isEmpty {
                movableSpritesTree.insert(s)
            }
        } else if let s = this as? BasicSprite & SKActionable {
            actionableSprites.insert(s)
            addChild(s.skNode)
            addChild(s.actionSprite)
            s.actionSprite.position = CGPoint(x: s.position.x, y: s.position.y)
            
            if !s.contactOn.isEmpty {
                movableSpritesTree.insert(s)
            }
        } else {
            quadtree.insert(this)
        }
        
        //addChild(this.helperNode)
        //(this.helperNode as? SKSpriteNode)?.anchorPoint = .zero
        //this.helperNode.alpha = 0.5
        //this.helperNode.position = .init(x: this.position.x, y: this.position.y)
        //print(this.helperNode.frame.size, this.helperNode.position)
    }
}

class MagicScene: SKScene {
    override func didMove(to view: SKView) { begin() }
    func begin() {}
}

var u = 16 // The unit!
class Scene: MagicScene {
    var magicCamera: SKCameraNode = .init()
    
    var players: [BasicSprite] = []
    var woah: SKNode!
    
    var actionableSprites: Set<BasicSprite> = []
    var movableSprites: Set<BasicSprite> = []
    var sprites: Set<BasicSprite> = []
    var quadtree: QuadTree = QuadTree.init(.init(x: -5120, y: -5120, width: 10240, height: 10240))
    var movableSpritesTree: QuadTree = QuadTree.init(.init(x: -5120, y: -5120, width: 10240, height: 10240))
    
    @discardableResult
    func build<T: BasicSprite>(_ this: T.Type, pos: (Int, Int), size: (Int, Int) = (1,1), player: Bool = false, image: String? = nil) -> T {
        let box = this.init(box: (this as? WhenActions2.Type)?.starterSize ?? (size.0*u,size.1*u), image: (this as? WhenActions2.Type)?.starterImage.rawValue ?? image)
        box.startPosition((pos.0*u,pos.1*u))
        box.add(self)
        if player { players.append(box); woah = (box as! MovableSprite).skNode } // add player
        add(box)
        return box
    }
    var massiveHeight = 0
    var massiveWidth = 0
    
    override func begin() {
        print("REBEGIN?")
        removeAction(forKey: "song")
        
        BackgroundMusic.stop()
        BackgroundMusic.play(.overworldTheme)
        
        
        Cash.scene = self
        quadtree = QuadTree.init(.init(x: -5120, y: -5120, width: 10240, height: 10240))
        movableSpritesTree = QuadTree.init(.init(x: -5120, y: -5120, width: 10240, height: 10240))
        sprites.removeAll(); movableSprites.removeAll(); actionableSprites.removeAll(); players.removeAll()
        
        if let loadScene = SKScene.init(fileNamed: "1-1") {
            backgroundColor = loadScene.backgroundColor
            for i in loadScene.children {
                guard let tileNode = i as? SKTileMapNode else { fatalError() }
                guard let tileName = i.name else { fatalError() }
                assert(tileNode.tileSize.width == tileNode.tileSize.height)
                tileNode.setScale(u.cg / tileNode.tileSize.width)
                //u = Int(tileNode.tileSize.width)

                let numberOfColumns = tileNode.numberOfColumns
                let numberOfRows = tileNode.numberOfRows
                massiveHeight = numberOfRows
                massiveWidth = numberOfColumns
                
                var tileToUse: BasicSprite.Type? = nil
                switch tileName {
                case "bg": tileNode.removeFromParent(); addChild(tileNode); continue
                case "GROUND": tileToUse = GROUND.self; tileNode.removeFromParent(); addChild(tileNode)
                case "QuestionBlock": tileToUse = QuestionBox.self
                case "BrickBlock": tileToUse = BrickBox.self
                case "Anim": tileToUse = nil
                    
                case "None": continue
                default: fatalError()
                }
                //tileNode.name

                for x in 0..<numberOfColumns {
                    for y in 0..<numberOfRows {

                        if let tile = tileNode.tileGroup(atColumn: x, row: y) {
                            if let tileName = tile.name {
                                
                                if let tileToUse = tileToUse {
                                    let _ = build(tileToUse, pos: (x,y), image: tileName)
                                } else {
                                    var newTileToUse: BasicSprite.Type!// = Goomba.self
                                    switch tileName {
                                    case "Goomba": newTileToUse = Goomba.self
                                    case "Koopa": newTileToUse = Koopa.self
                                    case "BrickBlock": newTileToUse = BrickBox.self
                                    case "QuestionBlock": newTileToUse = QuestionBox.self
                                    default: fatalError()
                                    }
                                    let _ = build(newTileToUse, pos: (x,y), image: tileName)
                                }
                                
                                //print("- Just Added", tileName)
                            }

                        }
                    }
                }

            }
        }
        
        
        let player = build(Inky.self, pos: (3,2), player: true)
        
        let _ = build(GROUND.self, pos: (-1,0), size: (1,massiveHeight*2))
        let _ = build(GROUND.self, pos: (massiveWidth,0), size: (1,massiveHeight*2))
        
        
        //let g0 = build(GROUND.self, pos: (0,-3), size: (69,2), image: "Ground")
        //let g1 = build(GROUND.self, pos: (g0.maxX/u+2,0), size: (15,2))
        //let g2 = build(GROUND.self, pos: (g1.maxX/u+3,0), size: (43,2))
        //let g3 = build(GROUND.self, pos: (g2.maxX/u+2,0), size: (43,2))
//        let pipe1 = build(GROUND.self, pos: (28,2), size: (2,2))
//        let pipe2 = build(GROUND.self, pos: (38,2), size: (2,3))
//        let pipe3 = build(GROUND.self, pos: (46,2), size: (2,4))
//        let pipe4 = build(GROUND.self, pos: (57,2), size: (2,4))
        
        
        //let q = build(QuestionBox.self, pos: (1, 9), image: "QuestionBlock")
        
        
        
        otherThings()
    }
    
    func otherThings() {
        //addChild(SKSpriteNode.init(color: .gray, size: CGSize.init(width: 10, height: 10)))
        
        camera = magicCamera
        magicCamera.position.y = scene!.frame.height/2
        magicCamera.position.x = woah.position.x
        addChild(magicCamera)
    }
    
    
    var pressingUp: Bool = false
    var pressingLeft: Bool = false
    var pressingRight: Bool = false
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 123, !pressingLeft { pressingLeft = true }
        if event.keyCode == 124, !pressingRight { pressingRight = true }
        if event.keyCode == 49 {
            pressingUp = true
        }
    }
    var releasingUp: Bool = false
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 123 { pressingLeft = false }
        if event.keyCode == 124 { pressingRight = false }
        if event.keyCode == 49 {
            releasingUp = true
            if (players[0] as? MovableSprite)?.dead == true {
                releasingUp = false
                removeAllActions()
                removeAllChildren()
                begin()
                return
            }
            
            //pressingUp = false
            //doThisWhenJumpButtonIsReleased.run()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Run Camera
        magicCamera.run(.moveTo(x: max(frame.width/2, min(woah.position.x, (massiveWidth.cg*u.cg)-(frame.width/2))), duration: 0.1))
        magicCamera.run(.moveTo(y: max(frame.height/2, min(woah.position.y, (massiveHeight.cg*u.cg)-(frame.height/2))), duration: 0.1))
        
        currentView = frame
        currentView = currentView.offsetBy(dx: magicCamera.position.x - (frame.width/2), dy: magicCamera.position.y - (frame.height/2))
        paddedView = currentView.someWhatOffScreen()
        //let bounds = foo.skNode.frame
        //guard var sceneBounds = foo.skNode.scene?.frame else { return }
        //guard let cameraPos = foo.skNode.scene?.camera?.position else { return }
        //sceneBounds = sceneBounds.offsetBy(dx: cameraPos.x - (sceneBounds.width/2), dy: cameraPos.y - (sceneBounds.height/2))
    }
    
    
    override func didFinishUpdate() {
        let d1 = Date().timeIntervalSince1970
        //let foo = DispatchQueue.init(label: "")
        //foo.async { [self] in
        
        let pressedRight = pressingRight// if pressingRight { doThisWhenRightButtonIsPressed.run() }
        let pressedLeft = pressingLeft// { doThisWhenLeftButtonIsPressed.run() }
        let pressedUp = pressingUp; pressingUp = false
        let releasedUp = releasingUp; releasingUp = false
        
        // Run SKActions on Actionable Sprites (Must be inside this didFinishUpdate func)
        for i in actionableSprites {
            if let j = i as? (ActionSprite & SKActionable) {
                if j.actionSprite.hasActions() {
                    i.setPosition((Int(j.actionSprite.frame.minX), Int(j.actionSprite.frame.minY)))
                } else if j.actionSprite.position != .zero {
                    i.setPosition((Int(j.actionSprite.frame.minX), Int(j.actionSprite.frame.minY)))
                }
            }
        }

        var massive = 0
        // Run any `.always` actions
        for i in Array(movableSprites) + Array(actionableSprites) {
            // Maybe try to optimize this line.
            i.everyFrame.run()
            massive += i.everyFrame.count
            
            if i.attachedToButtons {
                
                if pressedLeft, pressedRight {
                    // Hahaha. Can't move right and left at the same time ;)
                } else {
                    if pressedRight { i.doThisWhenRightButtonIsPressed.run() }
                    if pressedLeft { i.doThisWhenLeftButtonIsPressed.run() }
                    if pressedLeft || pressedRight {
                        i.doThisWhenRightOrLeftIsPressed.run()
                    } else {
                        i.doThisWhenNOTRightOrLeftIsPressed.run()
                    }
                }
                
                if pressedUp {
                    i.doThisWhenJumpButtonIsPressed.run()
                }
                if releasedUp { i.doThisWhenJumpButtonIsReleased.run() }
                
            }
            
            
            // Carry things. (Soon: Make this generic enum code as well.)
            // Move with Ground X
            if let j = i as? MovableSprite {
                for k in j.onGround {
                    
                    if k.velocity.dx != 0 {
                        let wow = i.previousPosition.x
                        i.position.x += k.velocity.dx
                        i.previousPosition.x = wow
                    }
                }
            }
        }
        
        // Check all Moving Sprites for collisions.
        // Create a Quadtree for Moving Objects
        //let movableSpritesTree = QuadTree.init(self.quadtree.size)
        
        for i in self.movableSprites {
            // Insert all Moving Sprites
            if i.velocity != (0,0) {
                movableSpritesTree.move(i)
            }
        }
        
        for i in self.actionableSprites {
            // Insert all Moving Action Sprites
            if i.velocity != (0,0) {
                movableSpritesTree.move(i)
            }
        }
        
        for i in self.movableSprites {
            if i.velocity == (0,0) { continue }
            if i.contactOn == [] { continue }
            self.checkForCollision(i, movableSpritesTree)
        }
        
        // Stay on Higher Ground
        for i in movableSprites {
            
            if let i = i as? MovableSprite {
                
                // If not on groud, fall
//                if i.onGround.isEmpty {
//                    i.doThisWhenNotOnGround.run(i)
//                }
                
                var groundsRemoved: [BasicSprite] = []
                let iOnGround = i.onGround
                
                i.onGround = i.onGround.filter { j in
                    
                    // If ground is dead
                    if j.dead {
                        groundsRemoved.append(j)
                        return !true
                    }
                    
                    // Only stick on the highest ground.
                    if iOnGround.contains(where: { $0.maxY > j.maxY }) {
                        return !true
                    }
                    
                    // Stick to the highest ground if not already on it.
                    if i.position.y != j.maxY {
                        i.position.y = j.maxY
                    }
                    
                    // Check if still on Ground...
                    if j.midX < i.midX {
                        if !(i.minX >= j.maxX) == false { groundsRemoved.append(j) }
                        return !(i.minX >= j.maxX)
                    }
                    if i.midX < j.midX {
                        if !(i.maxX <= j.minX) == false { groundsRemoved.append(j) }
                        return !(i.maxX <= j.minX)
                    }
                    
                    return !false
                }
                
//                if !groundsRemoved.isEmpty {
//                    print("NOonono")
//                }
                
                // Check if standing on Ledge
                if !i.onGround.isEmpty {
                    let wow1 = iOnGround.sorted(by: { $0.maxX > $1.maxX })
                    let wow2 = iOnGround.sorted(by: { $0.minX < $1.minX })
                    
                    if i.maxX > wow1[0].maxX {
                        i.standingOnLedge(n: wow1[0])
                    } else if i.minX < wow2[0].minX {
                        i.standingOnLedge(n: wow2[0])
                    } else {
                        i.standingOnLedge(n: nil)
                    }
                } else {
                    i.standingOnLedge(n: nil)
                }
            }
        }
        
        //print(d2 - d1)
        if Date().timeIntervalSince1970 - d1 > 0.02 {
            print("HRMPH", Date().timeIntervalSince1970 - d1)
        }
        
    }
    
}
