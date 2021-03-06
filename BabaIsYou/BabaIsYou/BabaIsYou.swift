//
//  BabaIsYou.swift
//  BabaIsYou
//
//  Created by Jonathan Pappas on 3/22/21.
//

import Foundation
import SpriteKit

typealias FakeCGPoint = (x: Int, y: Int)
var flounder: [ObjectType:[ObjectType]] = [:]

enum ObjectType: String {
    static var real: [ObjectType] = [.baba, .wall, .flag, .rock, water, skull, lava, ice, jelly, crab, star, keke, love]
    case baba, wall, flag, rock, water, skull, lava, grass, ice, jelly, crab, star, keke, love, algae, door, key, pillar
    
    case recursive = "r"
    case stop
    case defeat
    case win
    case you
    case `is`// = "is"
    case push, sink, hot, melt
    case and, move, open, shut // Move is the only new one
}


class Objects: Equatable {
    
    static func == (lhs: Objects, rhs: Objects) -> Bool {
        if lhs.objectType == .recursive, rhs.objectType == .recursive { return lhs.recursiveObjectType == rhs.recursiveObjectType }
        return lhs.objectType == rhs.objectType
    }
    
    var objectType: ObjectType {
        didSet { updateImage() }
    }
    var position: (x: Int, y: Int) = (0, 0) {
        didSet { sprite.position = .init(x: position.0 * spriteGrid, y: position.1 * spriteGrid) }
    }
    var recursiveObjectType: ObjectType = .baba {
        didSet { updateImage() }
    }
    var triedToMove = false
    var sprite: SKSpriteNode!
    
    func updateImage() {
        var imageName = objectType.rawValue
        if objectType == .recursive { imageName = recursiveObjectType.rawValue + "String" }
        sprite = .init(imageNamed: imageName)
        sprite.size = CGSize.init(width: spriteGrid, height: spriteGrid)
        sprite.texture?.filteringMode = .nearest
        if objectType == .baba { sprite.zPosition = 2 }
        if objectType == .recursive { sprite.zPosition = 1 }
    }
    
    required init(_ o: ObjectType) {
        objectType = o
    }
    
    static func Flag() -> Self { return Self.init(.flag) }
    static func Baba() -> Self { return Self.init(.baba) }
    static func Wall() -> Self { return Self.init(.wall) }
    static func Water() -> Self { return Self.init(.water) }
    static func C(_ n: ObjectType) -> Self { return .init(n) }
    static func R(_ n: ObjectType) -> Self { return Recursive(n) }
    static func Recursive(_ n: ObjectType) -> Self {
        let foo = Self.init(.recursive)
        foo.recursiveObjectType = n
        return foo
    }
    
    static func buildFrom(this: (ObjectType,ObjectType)?) -> Objects? {
        if let t = this {
            return t.0 == .recursive ? .R(t.1) : .C(t.0)
        }; return nil
    }
}


class Game: CustomStringConvertible {
    var description: String {
        var magOP = ""
        for i in 0..<Int(gridSize.y) {
            var op = ""
            (0..<Int(gridSize.x)).forEach { op += trueFindAtLocation(($0, i))?.objectType.rawValue ?? "." }
            magOP = "\(op)\n" + magOP
        }
        return "---\n" + magOP + "---"
    }
    
    var alive = true, win = false
    var gridSize: FakeCGPoint = (0, 0)
    var totalObjects: [Objects] = []
    var grid: [[Objects?]] = []
    
    func start() {
        grid = BabaIsYouLevels.getLevel()
        fixGrid()
    }
    
    func fixGrid() {
        gridSize = (grid[0].count, grid.count)
        spriteGrid = 1000 / max(gridSize.x, gridSize.y)
        grid.forEach { i in i.forEach { j in j?.updateImage() } }
        
        for i in 0..<Int(gridSize.y) {
            let y = Int(gridSize.y) - i - 1
            
            for j in 0..<Int(gridSize.x) {
                let x = j//gridSize.x - j - 1
                
                if let wow = grid[y][x] {
                    wow.position = (j, i)
                    totalObjects.append(wow)
                }
                
            }
        }
        
        findAllMatches()
        print(self)
    }
    
    func findAllMatches() {
        var newFlounder: [ObjectType:[ObjectType]] = [
            .recursive:[.push],
        ]
        
        let iso = totalObjects.filter { $0.objectType == .recursive && $0.recursiveObjectType == .is }
        
        for i in iso {
            // check up is down
            let check10 = findAtLocation(i.position, moveX: -1, moveY: 0)
            let check11 = findAtLocation(i.position, moveX: 1, moveY: 0)
            this: do {
                guard let c10 = check10?.first(where: { $0.objectType == .recursive }) else { break this }
                guard let c11 = check11?.first(where: { $0.objectType == .recursive }) else { break this }
                newFlounder[c10.recursiveObjectType] = (newFlounder[c10.recursiveObjectType] ?? []) + [c11.recursiveObjectType]
                
                // MASSIVE CHECKING FOR AND
                var findingValues: [ObjectType] = [c11.recursiveObjectType]
                var n = 2
                me: while true {
                    // Checking AND
                    let check12 = findAtLocation(i.position, moveX: n, moveY: 0)
                    let check13 = findAtLocation(i.position, moveX: n+1, moveY: 0)
                    guard let checkAND = check12?.first(where: { $0.objectType == .recursive }) else { break me }
                    guard let c13 = check13?.first(where: { $0.objectType == .recursive }) else { break me }
                    if checkAND.recursiveObjectType != .and { break me }
                    findingValues.append(c13.recursiveObjectType)
                    newFlounder[c10.recursiveObjectType] = (newFlounder[c10.recursiveObjectType] ?? []) + [c13.recursiveObjectType]
                    n += 2
                }
                
                var assigningValues: [ObjectType] = [c10.recursiveObjectType]
                n = -2
                me: while true {
                    // Checking AND
                    let check12 = findAtLocation(i.position, moveX: n, moveY: 0)
                    let check13 = findAtLocation(i.position, moveX: n-1, moveY: 0)
                    guard let checkAND = check12?.first(where: { $0.objectType == .recursive }) else { break me }
                    guard let c13 = check13?.first(where: { $0.objectType == .recursive }) else { break me }
                    if checkAND.recursiveObjectType != .and { break me }
                    assigningValues.append(c13.recursiveObjectType)
                    n -= 2
                }
                
                // Assigning them
                for i in assigningValues {
                    newFlounder[i] = (newFlounder[i] ?? []) + findingValues
                }
                
            }
            
            // check n is m (left is right)
            let check20 = findAtLocation(i.position, moveX: 0, moveY: 1)
            let check21 = findAtLocation(i.position, moveX: 0, moveY: -1)
            this: do {
                guard let c20 = check20?.first(where: { $0.objectType == .recursive }) else { break this }
                guard let c21 = check21?.first(where: { $0.objectType == .recursive }) else { break this }
                newFlounder[c20.recursiveObjectType] = (newFlounder[c20.recursiveObjectType] ?? []) + [c21.recursiveObjectType]
                
                // MASSIVE CHECKING FOR AND
                var findingValues: [ObjectType] = [c21.recursiveObjectType]
                var n = -2
                me: while true {
                    // Checking AND
                    let check12 = findAtLocation(i.position, moveX: 0, moveY: n)
                    let check13 = findAtLocation(i.position, moveX: 0, moveY: n-1)
                    guard let checkAND = check12?.first(where: { $0.objectType == .recursive }) else { break me }
                    guard let c13 = check13?.first(where: { $0.objectType == .recursive }) else { break me }
                    if checkAND.recursiveObjectType != .and { break me }
                    findingValues.append(c13.recursiveObjectType)
                    newFlounder[c20.recursiveObjectType] = (newFlounder[c20.recursiveObjectType] ?? []) + [c13.recursiveObjectType]
                    n -= 2
                }
                
                var assigningValues: [ObjectType] = [c20.recursiveObjectType]
                n = 2
                me: while true {
                    // Checking AND
                    let check12 = findAtLocation(i.position, moveX: 0, moveY: n)
                    let check13 = findAtLocation(i.position, moveX: 0, moveY: n+1)
                    guard let checkAND = check12?.first(where: { $0.objectType == .recursive }) else { break me }
                    guard let c13 = check13?.first(where: { $0.objectType == .recursive }) else { break me }
                    if checkAND.recursiveObjectType != .and { break me }
                    assigningValues.append(c13.recursiveObjectType)
                    n += 2
                }
                
                // Assigning them
                for i in assigningValues {
                    newFlounder[i] = (newFlounder[i] ?? []) + findingValues
                }
            }
        }
        
        for i in totalObjects {
            if ObjectType.real.contains(i.objectType) {
                if let cops = newFlounder[i.objectType]?.first(where: { ObjectType.real.contains($0) }) {
                    i.objectType = cops
                }
            }
        }
        
        if !newFlounder.contains(where: { $0.value.contains(.you) }) {
            print("GAME OVER BRUH")
            alive = false
            return
        }
        if !totalObjects.contains(where: { newFlounder[$0.objectType]?.contains(.you) == true }) {
            print("ALSO GAME OVER BRUH")
            alive = false
            return
        }
        alive = true
        flounder = newFlounder
    }
    
    
    @discardableResult
    func move(_ dir: Cardinal) -> Bool {
        if !alive { return false }
        
        undo.append(totalObjects.map { ($0, $0.position, $0.objectType) })
        for i in totalObjects { i.triedToMove = false }
        var didAnythingMove = false
        
        let you = totalObjects.filter { $0.objectType == .you || flounder[$0.objectType]?.contains(.you) == true }
        
        for i in you {
            if i.triedToMove {
                print("\(i.objectType) was already pushed")
                continue
            }
            
            if tryToMove(i, dir) {
                didAnythingMove = true
            } else {
                print("You did not move up!")
            }
            
        }
        
        findAllMatches()
        return didAnythingMove
    }
    
    enum Cardinal: Int { case up, down, left, right, none
        func xMove() -> Int { return [0, 0, -1, 1, 0][self.rawValue] }
        func yMove() -> Int { return [1, -1, 0, 0, 0][self.rawValue] }
    }
    
    func tryToMove(_ i: Objects,_ dir: Cardinal) -> Bool {
        //i.triedToMove = true
        
        guard let f = findAtLocation(i.position, moveX: dir.xMove(), moveY: dir.yMove()) else {
            return false
            
        }
        if f.isEmpty { reallyMove(i, dir); return true }
        guard let found = f.first(where: { flounder[$0.objectType]?.isEmpty == false }) else {
            // What if *YOU* are sink?
            if flounder[[i.objectType]].contains(.sink) {
                totalObjects = totalObjects.filter { $0 !== i && !f.contains($0) }
            }
            reallyMove(i, dir); return true
        }
        
        
        let foundTypes = flounder[f.objectTypes]
        
        // Push is first priority
        if foundTypes.contains(.push) {
            if !tryToMove(f.firstWith(.push), dir) {
                print(f.map { $0.objectType })
                return false
            }
        }
        
        // Push YOU is first priority
        if foundTypes.contains(.you) {
            
        }
        
        // Stop is first priority
        if foundTypes.contains(.stop) {
            return false
        }
        
        // Die is 2nd priority (Destory any objects with a die)
        if foundTypes.contains(.defeat) {
            if !f.allThatAre(.defeat).allContain(.push) {
                if flounder[[i.objectType]].contains(.you) {
                    totalObjects = totalObjects.filter { $0 !== i }
                }
            }
        }
        
        // Die is 2nd priority (Destory any objects with a die)
        if foundTypes.contains(.sink)  {
            if !f.allThatAre(.sink).allContain(.push) {
                totalObjects = totalObjects.filter { $0 !== i && $0 !== found }
            }
        }
        // What if *YOU* are sink?
        if flounder[[i.objectType]].contains(.sink) {
            let woah = f.allThatAreNot([.push, .stop])
            if !woah.isEmpty {
                totalObjects = totalObjects.filter { $0 !== i && !woah.contains($0) }
            }
        }
        
        if foundTypes.contains(.hot) {
            if !f.allThatAre(.hot).allContain(.push) {
                if flounder[[i.objectType]].contains(.melt) {
                    totalObjects = totalObjects.filter { $0 !== i }
                }
            }
        }
        
        // Win is FINAL priority
        if flounder[f.objectTypes].contains(.win)  {
            if flounder[i.objectType]?.contains(.you) == true {
                win = true
                print("YOU WIN THE GAME")
                return false
            }
        }
        
        return reallyMove(i, dir)
    }
    
    @discardableResult
    func reallyMove(_ i: Objects,_ dir: Cardinal) -> Bool {
        if i.triedToMove { return false }
        i.triedToMove = true
        i.position.x += dir.xMove()
        i.position.y += dir.yMove()
        print("\(i.objectType) Moved (\(dir.xMove()), \(dir.yMove())) spaces")
        return true
    }
    
    func findAtLocation(_ currentPos: FakeCGPoint, moveX: Int, moveY: Int) -> [Objects]? {
        let yo = currentPos.y + moveY
        if yo < 0 || yo >= gridSize.y { return nil }
        
        let xo = currentPos.x + moveX
        if xo < 0 || xo >= gridSize.x { return nil }
        
        return totalObjects.filter { $0.position == (xo, yo) }// (totalObjects.first(where: { $0.position == (xo, yo) }), true)
    }
    func trueFindAtLocation(_ currentPos: FakeCGPoint) -> Objects? {
        return totalObjects.first(where: { $0.position == currentPos })
    }
    
    var undo: [[(Objects, FakeCGPoint, ObjectType)]] = []
    func undoMove() {
        if let woah = undo.last {
            print("TRYING TO UNDO")
            undo.removeLast()
            totalObjects = woah.map {
                $0.0.position = $0.1
                $0.0.objectType = $0.2
                return $0.0
            }
            findAllMatches()
        }
    }
    func reset() {
        if !undo.isEmpty {
            undo = [undo[0]]
            undoMove()
        }
    }
    
}

extension Dictionary where Key == ObjectType, Value == [ObjectType] {
    subscript(_ this: [ObjectType]) -> Value {
        return this.map { self[$0] ?? [] }.flatMap { $0 }
    }
}
extension Array where Element == Objects {
    var objectTypes: [ObjectType] {
        return self.map { $0.objectType }
    }
    func firstWith(_ type: ObjectType) -> Objects {
        return first(where: { flounder[$0.objectType]?.contains(type) == true })!
    }
    func allThatAre(_ type: ObjectType) -> [Objects] {
        return filter { flounder[$0.objectType]?.contains(type) == true }
    }
    func allThatAreNot(_ type: [ObjectType]) -> [Objects] {
        return filter { Set(type).intersection(flounder[$0.objectType] ?? []).isEmpty }
    }
    func allContain(_ type: ObjectType) -> Bool {
        return filter { flounder[$0.objectType]?.contains(type) == false }.isEmpty
    }
}
