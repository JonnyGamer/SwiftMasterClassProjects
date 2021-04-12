//
//  Platformer.swift
//  PlatformerGameTest
//
//  Created by Jonathan Pappas on 4/12/21.
//

import Foundation
import SpriteKit






class Sprites: BasicSprite, Spriteable {
    var specificActions: [When] { [
        .stopObjectFromMoving(.up, when: .thisBumped(.up)),
        .stopObjectFromMoving(.down, when: .thisBumped(.down)),
        .stopObjectFromMoving(.left, when: .thisBumped(.left)),
        .stopObjectFromMoving(.right, when: .thisBumped(.right)),
    ] }
}

class Inky: Sprites {
    override var specificActions: [When] {
        return super.specificActions + [
            .jumpWhen(.pressedButton(.jump)),
            .moveLeftWhen(.pressedButton(.left)),
            .moveRightWhen(.pressedButton(.right)),
        ]
    }
    override var isPlayer: Bool { return true }
}



// Rule For All Enemies
class Enemy: BasicSprite, Spriteable {
    var specificActions: [When] { [] }
}

// Rule for Specific Enemies
class Chaser: Enemy {
    override var specificActions: [When] {
        return super.specificActions + [
            .moveLeftWhen(.playerIsLeftOfSelf),
            .moveRightWhen(.playerIsRightOfSelf)
        ]
    }
}

class Trampoline: BasicSprite, Spriteable {
    
    var bounciness: Int = 0
    
    var specificActions: [When] {[
        .bounceObjectWhen(.thisBumped(.up)),
            
        .stopObjectFromMoving(.down, when: .thisBumped(.down)),
        .stopObjectFromMoving(.left, when: .thisBumped(.left)),
        .stopObjectFromMoving(.right, when: .thisBumped(.right)),
    ]}
    
}






