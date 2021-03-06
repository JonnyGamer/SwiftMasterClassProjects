//
//  Collision.swift
//  PlatformerGameTest
//
//  Created by Jonathan Pappas on 4/13/21.
//

import Foundation
import SpriteKit

extension Scene {
    func checkForCollision(_ j: BasicSprite,_ movableSpritesTree: QuadTree) {
        
        if j.contactOn.isEmpty { return }
        if j.dead { return }
        
        let d1 = Date.init().timeIntervalSince1970
        let superSet = movableSpritesTree.contains(j).union(quadtree.contains(j))
        let d2 = Date.init().timeIntervalSince1970
        //print(d2 - d1)
        if d2 - d1 > 0.01 {
            print("HRMPHY", superSet.count)
        }
        defer {
            if Date.init().timeIntervalSince1970 - d1 > 0.01 {
                print("HRMPHY", superSet.count)
            }
        }
//        if superSet.count > 10 {
//            print("HRMPH", superSet)
//        }
        
        for i in superSet {//} sprites.shuffled() {
            if i === j { continue }
            if i.contactOn.isEmpty { continue }
            if i.dead { continue }
            if !i.trajectoryX().overlaps(j.trajectoryX()) { continue }
            if !i.trajectoryY().overlaps(j.trajectoryY()) { continue }

            
            // Falling Down
            foo: if let j = j as? MovableSprite {
                //if !(i.minX..<i.maxX).overlaps(j.minX..<j.maxX) { break foo }
                
                if i.velocity.dy == 0, j.velocity.dy == 0 {
                    if (i as? MovableSprite)?.onGround.contains(j) == true { break foo }
                    if j.onGround.contains(i) == true { break foo }
                    //break foo
                }
                
                do {
                    
                    var jRange: ClosedRange<Int> = j.minX...j.maxX
                    if j.velocity.dx < 0 {
                        jRange = ((j.minX)...(j.previousPosition.x + j.frame.x))
                    } else if j.velocity.dx > 0 {
                        jRange = ((j.previousPosition.x)...(j.maxX))
                    }
                    
                    var iRange: ClosedRange<Int> = i.minX...i.maxX
                    if i.velocity.dx < 0 {
                        iRange = ((i.minX)...(i.previousPosition.x + i.frame.x))
                    } else if i.velocity.dx > 0 {
                        iRange = ((i.previousPosition.x)...(i.maxX))
                    }
                    
                    if jRange.overlaps(iRange) {
                        if jRange.upperBound == iRange.lowerBound {
                            continue
                        }
                        if jRange.lowerBound == iRange.upperBound {
                            continue
                        }
                    } else {
                        continue
                    }
                }
                
                
                
                if j.onGround.contains(where: { $0 === i }) { break foo }
                if (i as? MovableSprite)?.onGround.contains(where: { $0 === j }) == true { break foo }
                
                if j.velocity.dy == 0, i.velocity.dy == 0 {
                    if j.maxY == i.minY, j.onGround.isEmpty {
                        i.contactTest(.up, bumpedBy: j) // Hit two ? Blocks at once
                    } else if j.minY == i.maxY, !j.onGround.isEmpty {
                        i.contactTest(.down, bumpedBy: j) // Walk onto another ground of the same Y position
                    }
                    
                } else if j.velocity.dy == 0, i.velocity.dy >= 0 {
                    if ((i.previousPosition.y+i.frame.y)...i.maxY).contains(j.minY) { // Fixed (previousMaxY)
                        if j.previousMaxX == i.minX { break foo } //
                        if j.previousMinX == i.maxX { break foo } //
                        i.contactTest(.down, bumpedBy: j)
                    }
                    
                    
                } else if j.velocity.dy < 0, i.velocity.dy >= 0 {
                    
                    if (j.minY...(j.previousPosition.y+j.frame.y)).contains(i.maxY) {
                        if j.previousMaxX == i.minX { break foo } //
                        if j.previousMinX == i.maxX { break foo } //
                        i.contactTest(.down, bumpedBy: j)
                    }
                
                } else if j.velocity.dy > 0, i.velocity.dy <= 0 {
                    if (j.previousPosition.y...j.maxY).contains(i.minY) {
                        if j.previousMaxX <= i.minX { break foo } //
                        if j.previousMinX >= i.maxX { break foo } //
                        i.contactTest(.up, bumpedBy: j)
                    }
                    
                // Both are moving downwards
                } else if j.velocity.dy < 0, i.velocity.dy < 0 {
                    if i.previousPosition.y < j.previousPosition.y {
                        if (i.position.y...i.previousPosition.y+i.frame.y).overlaps(j.position.y...j.previousPosition.y+i.frame.y) {
                            if j.velocity.dy < i.velocity.dy {
                                i.contactTest(.down, bumpedBy: j)
                            }
                        }
                    } else if i.previousPosition.y > j.previousPosition.y {
                        
                    }
                // If both are moving upwards
                } else if j.velocity.dy > 0, i.velocity.dy > 0 {
                    
                    // If i was lower than j.
                    if i.previousPosition.y < j.previousPosition.y {
                        if i.maxY > j.minY {
                            i.contactTest(.down, bumpedBy: j)
                        }
                    }
                }
                
            }
            
            if i.velocity.dx == 0, j.velocity.dx == 0 {
                //continue
            }
            
            newCheckX(i, j, sprites: superSet)
            newCheckX(j, i, sprites: superSet) // I really don't like this, but it somehow works :(
            
            continue
        }
    }
    
    
    func recursiveRightPush(_ j: BasicSprite, velX: Int, sprites: Set<BasicSprite>) -> (BasicSprite, Int)? {
        
        if j as? MovableSprite == nil {
            return (j, 0)
        }
        
        for i in sprites {
            if i === j { continue }
            
            if i.midX > j.midX {
                if j.midY > i.midY {
                    if j.minY >= i.maxY { continue }
                } else {
                    if j.maxY <= i.minY { continue }
                }
                
                // Only Runs When Side by Side
                if i.maxX > j.minX, i.minX < j.maxX {
                    if i.velocity.dx == -j.velocity.dx {
                    } else if -i.velocity.dx < j.velocity.dx {
                        return recursiveMiniGeneralPush(i, j, velX: velX, dir: .right, recur: recursiveRightPush, sprites: sprites)
                    } else {
                    }
                }
            }
        }
        return nil
    }
    
    func recursiveLeftPush(_ i: BasicSprite, velX: Int, sprites: Set<BasicSprite>) -> (BasicSprite, Int)? {
        
        if i as? MovableSprite == nil {
            return (i, 0)
        }
        
        for j in sprites {
            if i === j { continue }
            
            if i.midX > j.midX {
                if j.midY > i.midY {
                    if j.minY >= i.maxY { continue }
                } else {
                    if j.maxY <= i.minY { continue }
                }
                
                // Only Runs When Side by Side
                if i.maxX > j.minX, i.minX < j.maxX {
                    if i.velocity.dx == -j.velocity.dx {
                    } else if -i.velocity.dx < j.velocity.dx {
                    } else {
                        return recursiveMiniGeneralPush(j, i, velX: velX, dir: .left, recur: recursiveLeftPush, sprites: sprites)
                    }
                }
            }
        }
        //print("NOSIR")
        return nil
        
    }
    
    func recursiveMiniGeneralPush(_ i: BasicSprite, _ j: BasicSprite, velX: Int, dir: Direction, recur: (BasicSprite,Int,Set<BasicSprite>) -> (BasicSprite, Int)?, sprites: Set<BasicSprite>) -> (BasicSprite, Int)? {
        if j as? MovableSprite == nil {
            return (j, 0)
        }
        if i as? MovableSprite == nil {
            return (i, 0)
        }
        
        if let j = j as? MovableSprite {
            if dir == .left {
                //i.bumpedFromLeft.run(j)
            } else if dir == .right {
                //i.bumpedFromRight.run(j)
            }
            if i.velocity.dx == 0 {
                return (j, 0)
            }
            if let _ = recur(i, velX, sprites) {
                j.stopMoving(i, dir)
                return (j, 0)
            }
        }
        return nil
    }
    
    
    func newCheckX(_ i: BasicSprite,_ j: BasicSprite, sprites: Set<BasicSprite>) {
        foo: if j.previousMidX < i.previousMidX {
            
            do {
                
                var jRange: ClosedRange<Int> = j.minY...j.maxY
                if j.velocity.dy < 0 {
                    jRange = ((j.minY)...(j.previousPosition.y + j.frame.y))
                } else if j.velocity.dy > 0 {
                    jRange = ((j.previousPosition.y)...(j.maxY))
                }
                
                var iRange: ClosedRange<Int> = i.minY...i.maxY
                if i.velocity.dy < 0 {
                    iRange = ((i.minY)...(i.previousPosition.y + i.frame.y))
                } else if i.velocity.dy > 0 {
                    iRange = ((i.previousPosition.y)...(i.maxY))
                }
                
                if jRange.overlaps(iRange) {
                    if jRange.upperBound == iRange.lowerBound {
                        return
                    }
                    if jRange.lowerBound == iRange.upperBound {
                        return
                    }
                } else {
                    return
                }
            }
            
            
            if true {// } i.maxX > j.minX, i.minX < j.maxX { // j.previousMaxX <= i.previousMinX, j.maxX >= i.minX {//}
                
                
                if i.velocity.dx == 0, let j = j as? MovableSprite {
                    // j -> |i|
                    if j.previousMaxX > i.previousMinX {
                        break foo
                    }
                    
                    if j.velocity.dx > 0 {
                        if i.minY > j.maxY { break foo }
                        if i.minY + i.velocity.dy >= j.maxY { break foo }
                        
                        i.contactTest(.right, bumpedBy: j)
                        //i.bumpedFromRight.run(j)
                        if let i = i as? MovableSprite {
                            //j.bumpedFromLeft.run(i) // Do I need this?
                            
                            if let _ = recursiveRightPush(i, velX: i.velocity.dx, sprites: sprites) {
                                j.stopMoving(i, .right)
                            }
                        }
                    }
                    
//                    if j.previousPosition.x - j.velocity.dx + j.frame.x > i.minX {
//                        print(j.velocity)
//                        break foo
//                    }

                    
                } else if let i = i as? MovableSprite {
                    if j.velocity.dx == 0 {
                        // |j| <- i
                        if i.previousPosition.x - i.velocity.dx < j.maxX { break foo }
                        if i.minY > j.maxY { break foo }
                        if i.maxY < j.minY { break foo }
                        if j.minY + j.velocity.dy >= i.maxY { break foo }
                        
                        j.contactTest(.left, bumpedBy: i)
                        //j.bumpedFromLeft.run(i)
                        if let j = j as? MovableSprite {
                            //i.bumpedFromRight.run(j) // Do I need this?
                            if let _ = recursiveLeftPush(j, velX: j.velocity.dx, sprites: sprites) {
                                i.stopMoving(j, .left)
                            }
                            
                        }
                        
                    } else if let j = j as? MovableSprite {
                        if i.velocity.dx < 0 {
                            if j.velocity.dx < 0 {
                                
                                if j.velocity.dx == i.velocity.dx {
                                    // <- j <- i
                                    // do nothing SAME OLD thing as the one below
                                    
                                    if !(j.minX...(j.previousPosition.x + j.frame.x)).overlaps((i.minX...i.previousPosition.x)) { break foo }
                                    //j.bumpedFromLeft.run(i)
                                    //i.bumpedFromRight.run(j)
                                    if let _ = recursiveLeftPush(j, velX: j.velocity.dx, sprites: sprites) {
                                        i.stopMoving(j, .left)
                                    }
                                    
                                } else {
                                    
                                    // <- j <-<- i
                                    if j.previousMaxX > i.previousMinX { break foo }
                                    if j.maxX < i.minX { break foo }
                                    if !(j.minX...(j.previousPosition.x + j.frame.x)).overlaps((i.minX...i.previousPosition.x)) { break foo }
                                    j.contactTest(.left, bumpedBy: i)
                                    //j.bumpedFromLeft.run(i)
                                    //i.bumpedFromRight.run(j)
                                    
                                    if let _ = recursiveLeftPush(j, velX: j.velocity.dx, sprites: sprites) {
                                        i.stopMoving(j, .left)
                                    }
                                    
                                }
                                
                            } else {
                                if j.velocity.dx == -i.velocity.dx {
                                    // Unfinished
                                    // j -> <- i
                                    j.contactTest(.left, bumpedBy: i)
                                    i.contactTest(.right, bumpedBy: j)
                                    //j.bumpedFromLeft.run(i)
                                    //i.bumpedFromRight.run(j)
                                    
                                    i.position.x = i.previousPosition.x // Do Noy Delete these yet.
                                    j.position.x = j.previousPosition.x
                                    //i.stopMoving(j, .left)
                                    //j.stopMoving(i, .right)
                                    
                                    //i.runWhenBumpRight.run()
                                    //j.runWhenBumpLeft.run()
                                    
                                } else {
                                    
                                    if !((j.previousPosition.x + j.frame.x)...j.maxX).overlaps((i.minX...i.previousPosition.x)) { break foo }
                                    
                                    if j.velocity.dx > -i.velocity.dx {
                                        if i.minY > j.maxY { break foo }
                                        if i.minY + i.velocity.dy >= j.maxY { break foo }
                                        
                                        // j ->-> <- |i|
                                        j.contactTest(.left, bumpedBy: i)
                                        i.contactTest(.right, bumpedBy: j)
                                        //i.bumpedFromRight.run(j)
                                        //j.bumpedFromLeft.run(i)
                                        if let _ = recursiveRightPush(i, velX: i.velocity.dx, sprites: sprites) {
                                            j.stopMoving(i, .right)
                                        }
                                        
                                    } else {
                                        if i.maxX < j.minY { break foo }
                                        if j.minY + j.velocity.dy >= i.maxY { break foo }
                                        
                                        // j -> <-<- i
                                        j.contactTest(.left, bumpedBy: i)
                                        i.contactTest(.right, bumpedBy: j)
                                        //j.bumpedFromLeft.run(i)
                                        //i.bumpedFromRight.run(j)
                                        if let _ = recursiveLeftPush(j, velX: j.velocity.dx, sprites: sprites) {
                                            i.stopMoving(j, .left)
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        } else {
                            // THIS ACTUALLY SOMETIMES HAPPENS
                            //fatalError()
                            
                            // j ->-> i ->
                            if j.velocity.dx > 0 {
                                if !(j.previousPosition.x...j.maxX).overlaps(i.previousPosition.x...i.maxX) { break foo }
                                if i.velocity > j.velocity { break foo }
                                
                                if i.minY + i.velocity.dy >= j.maxY { break foo }
                                
                                if j.previousMinY >= (i.previousMaxY-1) {
                                    i.contactTest(.down, bumpedBy: j)
                                } else if i.previousMinY >= (j.previousMaxY-1) {
                                    j.contactTest(.down, bumpedBy: i)
                                } else {
                                    i.contactTest(.right, bumpedBy: j)
                                }
                                //i.bumpedFromRight.run(j)
                                //j.bumpedFromLeft.run(i)
                                if let _ = recursiveRightPush(i, velX: i.velocity.dx, sprites: sprites) {
                                    j.stopMoving(i, .right)
                                }
                            } else {
                                // Ignore this <- j i ->
                            }
                            
//                            if j.velocity.dx == i.velocity.dx {
//                                // j -> i ->
//                                // do nothing SAME OLD thing as the one below
//
//                                if !(j.minX...(j.previousPosition.x + j.frame.x)).overlaps((i.minX...i.previousPosition.x)) { break foo }
//                                j.bumpedFromLeft.forEach { $0(i) }
//                                if let _ = recursiveLeftPush(j, velX: j.velocity.dx) {
//                                    i.stopMoving(j, .left)
//                                }
//
//                            } else {
//
//                                // j ->-> i ->
//                                if !(j.previousPosition.x...j.maxX).overlaps(i.previousPosition.x...i.maxX) { break foo }
//                                i.bumpedFromRight.forEach { $0(j) }
//                                if let _ = recursiveRightPush(i, velX: i.velocity.dx) {
//                                    j.stopMoving(i, .right)
//                                }
//
                            //}
                            
                        }
                    }
                }
                
            }
        }
    }
    
    
}


//if !(i.minX..<i.maxX).overlaps(j.minX..<j.maxX) { break foo }
//if i.velocity.dy == 0, j.velocity.dy == 0 { break foo }
//
//if j.onGround.contains(where: { $0 === i }) { break foo }
//if (i as? MovableSprite)?.onGround.contains(where: { $0 === j }) == true { break foo }
//
//
//
//if j.velocity.dy < 0, i.velocity.dy == 0 {
//    // This line is needed, Otherwise bad bugs when pushing -> then jumping
//    if j.maxX - j.velocity.dx <= i.minX { break foo }
//    if j.minX - j.velocity.dx >= i.minX { break foo }
//    if (j.minY...(j.maxY + j.velocity.dy)).contains(i.maxY) {
//        i.bumpedFromBottom.forEach { $0(j) }
//    }
//
//} else if j.velocity.dy > 0, i.velocity.dy == 0 {
//    // This line is needed, Otherwise bad bugs when pushing -> then jumping
//    if j.maxX - j.velocity.dx <= i.minX { break foo }
//    if j.minX - j.velocity.dx >= i.minX { break foo }
//    if (j.minY...(j.maxY + j.velocity.dy)).contains(i.maxY) {
//        i.bumpedFromBottom.forEach { $0(j) }
//    }
//
//} else if j.velocity.dy == 0, i.velocity.dy == 0 {
//
//
//// ROUND 2
//} else if j.velocity.dy < 0, i.velocity.dy < 0 {
//
//} else if j.velocity.dy > 0, i.velocity.dy < 0 {
//
//} else if j.velocity.dy == 0, i.velocity.dy < 0 {
//
//// ROUND 3
//} else if j.velocity.dy < 0, i.velocity.dy > 0 {
//
//} else if j.velocity.dy > 0, i.velocity.dy > 0 {
//
//} else if j.velocity.dy == 0, i.velocity.dy > 0 {
//
//}
//
//break foo
