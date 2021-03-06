
import SpriteKit
import GameplayKit

var tenth: CGFloat = 10
var halfSpriteGrid: CGFloat = 50
var imageGrid: Int = 0
var spriteGrid: Int = 100 {
    didSet {
        halfSpriteGrid = CGFloat(spriteGrid) / 2
        tenth = CGFloat(spriteGrid) / 10
    }
}

var algaeEaten = 0
var starsEaten = 0
var loveEaten = 0

class GameScene: SKScene {
    let game = Game()
    var superNode = SKNode()
    
    override func didMove(to view: SKView) {
        print("Hello World WASSUP")
        game.start()
        resetChildren()
        
        addChild(superNode)
        superNode.position.x = CGFloat(game.gridSize.x) * -halfSpriteGrid + halfSpriteGrid
        superNode.position.y = CGFloat(game.gridSize.y) * -halfSpriteGrid + halfSpriteGrid
        
        let bgNodeWidth = CGFloat(game.gridSize.x * spriteGrid) + tenth
        let bgNodeHeight = CGFloat(game.gridSize.y * spriteGrid) + tenth
        let bgNode = SKSpriteNode.init(color: .black, size: .init(width: bgNodeWidth, height: bgNodeHeight))
        
        bgNode.position = .zero
        bgNode.zPosition = -1
        addChild(bgNode)
    }

    func resetChildren() {
        superNode.removeAllChildren()
        for i in game.totalObjects {
            i.sprite.position = .init(x: i.position.x * spriteGrid, y: i.position.y * spriteGrid)
            superNode.addChild(i.sprite)
        }
    }
    
    
    
    // Keys
    var workingOnMoving: Bool = false
    var ultimateWin = false
    var smackKey: Int? = nil
    var previousTime: Double = 0
    var previousEnemyTime: Double = Date().timeIntervalSince1970
    var gameover = false
    
    func gameOver() {
        if gameover { return }
        gameover = true
        
        let label1 = SKLabelNode.init(text: "Game Over!")
        addChild(label1)
        label1.position.y = 300
        label1.fontSize *= 3
        label1.fontName = ""
        label1.zPosition = 1000
        
        var newYPos: CGFloat = 200
        for i in [("Level", CustomLevel.discoveredLevels, totalLevels), ("Algae", algaeEaten, totalAlgaes), ("Stars", starsEaten, totalStars), ("Love", loveEaten, totalLove)] {
            if i.1 > 0 {
                
                let label2 = SKLabelNode.init(text: "\(i.0): \(i.1)")
                addChild(label2)
                label2.position.y = newYPos
                label2.fontName = ""
                label2.zPosition = 1000
                newYPos -= 50
                
                if i.1 > i.2 {
                    label2.text! += " (Record!)"
                }
                
            }
        }
        
        for i in [("Highscores",0), ("Level", totalLevels), ("Algae", totalAlgaes), ("Stars", totalStars), ("Love", totalLove)] {
            let label2 = SKLabelNode.init(text: "\(i.0): \(i.1)")
            if i.0 == "Highscores" { label2.text = i.0 }
            addChild(label2)
            label2.position.y = newYPos
            label2.fontName = ""
            label2.zPosition = 1000
            newYPos -= 50
        }
        
        if CustomLevel.discoveredLevels > totalLevels { totalLevels = CustomLevel.discoveredLevels }
        if loveEaten > totalLove { totalLove = loveEaten }
        if algaeEaten > totalAlgaes { totalAlgaes = algaeEaten }
        if starsEaten > totalStars { totalStars = starsEaten }
        
    }
    
}

var totalAlgaes: Int {
    get { UserDefaults.standard.integer(forKey: "Algae") }
    set { UserDefaults.standard.set(newValue, forKey: "Algae") }
}
var totalStars: Int {
    get { UserDefaults.standard.integer(forKey: "Stars") }
    set { UserDefaults.standard.set(newValue, forKey: "Stars") }
}
var totalLove: Int {
    get { UserDefaults.standard.integer(forKey: "Love") }
    set { UserDefaults.standard.set(newValue, forKey: "Love") }
}
var totalLevels: Int {
    get { UserDefaults.standard.integer(forKey: "Levels") }
    set { UserDefaults.standard.set(newValue, forKey: "Levels") }
}


extension GameScene {

    override func keyDown(with event: NSEvent) {
        if ultimateWin { return }
        print(event.keyCode)
        if smackKey != nil { return }
        smackKey = Int(event.keyCode)
        
        if workingOnMoving { return }
        workingOnMoving = true
        
        previousTime = Date().timeIntervalSince1970 + 0.1
        moveKey(Int(event.keyCode))
        
        superNode.alpha = game.alive ? 1 : 0.5
        if game.win {
            ultimateWin = true
            //level += 1 // Maybe increase or decrease position ;) (0, 0)
            let newScene = GameScene.init(size: CGSize(width: 1000, height: 1000))
            newScene.anchorPoint = .init(x: 0.5, y: 0.5)
            newScene.scaleMode = .aspectFit
            view?.presentScene(newScene)
        }
        
        workingOnMoving = false
    }
    
    func moveKey(_ n: Int) {
        switch n {
        case -1: game.move(.none, moveEnemies: true); resetChildren()
        case 126, 13: game.move(.up); resetChildren()
        case 123, 0: game.move(.left); resetChildren()
        case 125, 1: game.move(.down); resetChildren()
        case 124, 2: game.move(.right); resetChildren()
        //case 49: game.undoMove(); resetChildren()
        case 36,42:
            let newScene = GameScene.init(size: CGSize(width: 1000, height: 1000))
            newScene.anchorPoint = .init(x: 0.5, y: 0.5)
            newScene.scaleMode = .aspectFit
            if n != 42 {
                algaeEaten = 0
                starsEaten = 0
                loveEaten = 0
                CustomLevel.discoveredLevels = 0
            }
            view?.presentScene(newScene)
            return
            game.reset(); resetChildren()
            
        default: break// game.move(.none)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        let currTime = Date().timeIntervalSince1970
        
        // Move Elemies
        if !workingOnMoving, smackKey != 49 {
            if currTime > previousEnemyTime + 1 {
                previousEnemyTime = currTime
                moveKey(-1)
            }
        }
        
        if let smack = smackKey, !workingOnMoving {
            if currTime < previousTime + 0.1 { return }
            previousTime = currTime
            moveKey(smack)
        }
        
        if !game.alive {
            gameOver()
        }
        
    }
    
    override func keyUp(with event: NSEvent) {
        if let smack = smackKey, event.keyCode == smack {
            smackKey = nil
        }
    }
    
}
