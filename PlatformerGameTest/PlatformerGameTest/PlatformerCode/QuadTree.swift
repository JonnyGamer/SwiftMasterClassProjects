//
//  QuadTree.swift
//  PlatformerGameTest
//
//  Created by Jonathan Pappas on 4/12/21.
//

import Foundation
import SpriteKit

//typealias Ranger = ClosedRange<CGFloat>

extension BasicSprite {
    var minX: Int { return position.x }
    var minY: Int { return position.y }
    var maxX: Int { return position.x + frame.x }
    var maxY: Int { return position.y + frame.y }
    var midX: Int { return (minX + maxX)/2 }
    var midY: Int { return (minY + maxY)/2 }
    
    var previousMinX: Int { return previousPosition.x }
    var previousMidX: Int { return (previousMinX + previousMaxX)/2 }
    var previousMaxX: Int { return previousPosition.x + frame.x }
    var previousMinY: Int { return previousPosition.y }
    var previousMidY: Int { return (previousMinY + previousMaxY)/2 }
    var previousMaxY: Int { return previousPosition.y + frame.y }
    
    func doubleMyHeight() {
        frame.y *= 2
        (self as? MovableSprite)?.skNode.yScale *= 2
    }
    func halfMyHeight() {
        frame.y /= 2
        (self as? MovableSprite)?.skNode.yScale /= 2
    }
}

extension BasicSprite {
    func couldOverlap(_ with: BasicSprite) -> Bool {
        return true
        //return (previousPosition.x...maxX).overlaps((with.previousPosition.minX...with.maxX)) || (minY...maxY).overlaps((with.minY...with.maxY))
    }
    func trajectoryX() -> ClosedRange<CGFloat> {
        if velocity.dx == 0 {
            return minX.cg...maxX.cg
        }
        if velocity.dx < 0 {
            return minX.cg...(previousPosition.x+frame.x).cg
        } else {
            return previousPosition.x.cg...maxX.cg
        }
    }
    func trajectoryY() -> ClosedRange<CGFloat> {
        if velocity.dy == 0 {
            return minY.cg...maxY.cg
        }
        if velocity.dy < 0 {
            return minY.cg...(previousPosition.y+frame.y).cg
        } else {
            return previousPosition.y.cg...maxY.cg
        }
    }
}



class QuadTree {
    var qBL: QuadTree?
    var qTL: QuadTree?
    var qBR: QuadTree?
    var qTR: QuadTree?

    var elements: Set<BasicSprite> = []
    var jnodes: Set<BasicSprite> = []
    var size: CGRect
    var minSize: CGFloat = 1
    var split = false
    var level = 0

    init(_ this: CGRect) { size = this }
    
    // NEEDS TESTING
    func move(_ box: BasicSprite) {
        delete(box)
        insert(box)
    }
    
    // NEEDS TESTING
    func delete(_ box: BasicSprite) {
        
        let tX = box.trajectoryX()
        let tY = box.trajectoryY()
        
        if tX.overlaps(size.minX...size.midX) {
            if tY.overlaps(size.minY...size.midY) {
                elements.remove(box)
                qBL?.delete(box)
            }
            if tY.overlaps(size.midY...size.maxY) {
                elements.remove(box)
                qTL?.delete(box)
            }
        }
        if tX.overlaps(size.midX...size.maxX) {
            if tY.overlaps(size.minY...size.midY) {
                elements.remove(box)
                qBR?.delete(box)
            }
            if tY.overlaps(size.midY...size.maxY) {
                elements.remove(box)
                qTR?.delete(box)
            }
        }
        
    }

    // Find all Quadtrees containing box and it's velocity...
    func contains(_ box: BasicSprite) -> Set<BasicSprite> {
        var seto: Set<BasicSprite> = []
        
        if !elements.isEmpty {
            return elements
        }
        
        let tX = box.trajectoryX()
        let tY = box.trajectoryY()
        
        if tX.overlaps(size.minX...size.midX) {
            if tY.overlaps(size.minY...size.midY) {
                seto = seto.union(qBL?.contains(box) ?? qBL?.elements ?? [])
            }
            if tY.overlaps(size.midY...size.maxY) {
                seto = seto.union(qTL?.contains(box) ?? qTL?.elements ?? [])
            }
        }
        if tX.overlaps(size.midX...size.maxX) {
            if tY.overlaps(size.minY...size.midY) {
                seto = seto.union(qBR?.contains(box) ?? qBR?.elements ?? [])
            }
            if tY.overlaps(size.midY...size.maxY) {
                seto = seto.union(qTR?.contains(box) ?? qTR?.elements ?? [])
            }
        }
        
        return seto
    }

    var total: Int {
        if !elements.isEmpty { return elements.count }
        let bl = qBL?.total ?? 0
        let br = qBR?.total ?? 0
        let tl = qTL?.total ?? 0
        let tr = qTR?.total ?? 0
        return bl + br + tl + tr
    }
    var allObjects: Set<BasicSprite> {
        if !elements.isEmpty { return elements }
        let bl = qBL?.allObjects ?? []
        let br = qBR?.allObjects ?? []
        let tl = qTL?.allObjects ?? []
        let tr = qTR?.allObjects ?? []
        return bl.union(br).union(tl).union(tr)// + br + tl + tr
    }
    

    func insert(_ box: BasicSprite) {

        let minSquare = (minSize * minSize)
        elements.insert(box)
        
        // Don't include elements that are too small...
        if size.height < minSquare || size.height < minSquare { return }
        
        
        if elements.count <= 4 && !split { return }
        split = true

        let ele = elements; elements = []

        for element in ele {
            
            let tX = element.trajectoryX()
            let tY = element.trajectoryY()
            
            if tX.overlaps((size.minX...size.midX)) {
                
                if tY.overlaps(size.minY...size.midY) {
                    if qBL == nil {
                        qBL = QuadTree(size.lowerLeftQuadrant)
                        qBL?.level = level + 1
                    }
                    qBL?.insert(element)
                    //continue
                }
                if tY.overlaps(size.midY...size.maxY) {
                    if qTL == nil {
                        qTL = QuadTree.init(size.upperLeftQuadrant)
                        qTL?.level = level + 1
                    }
                    qTL?.insert(element)
                    //continue
                }
                
            }
            
            
            if tX.overlaps((size.midX...size.maxX)) {
                if tY.overlaps(size.minY...size.midY) {
                    if qBR == nil {
                        qBR = QuadTree(size.lowerRightQuadrant)
                        qBR?.level = level + 1
                    }
                    qBR?.insert(element)
                    //continue
                }
                if tY.overlaps(size.midY...size.maxY) {
                    if qTR == nil {
                        qTR = QuadTree(size.upperRightQuadrant)
                        qTR?.level = level + 1
                    }
                    qTR?.insert(element)
                    //continue
                }
            }
        }
    }
}



extension Int { var cg: CGFloat { CGFloat(self) } }
extension CGRect {
    
    var lowerLeftQuadrant: CGRect {
        return CGRect.init(origin: CGPoint(x: minX, y: minY), size: CGSize.init(width: size.width/2, height: size.height/2))
    }
    var lowerRightQuadrant: CGRect {
        return CGRect.init(origin: CGPoint(x: midX, y: minY), size: CGSize.init(width: size.width/2, height: size.height/2))
    }
    var upperLeftQuadrant: CGRect {
        return CGRect.init(origin: CGPoint(x: minX, y: midY), size: CGSize.init(width: size.width/2, height: size.height/2))
    }
    var upperRightQuadrant: CGRect {
        return CGRect.init(origin: CGPoint(x: midX, y: midY), size: CGSize.init(width: size.width/2, height: size.height/2))
    }
    
}
