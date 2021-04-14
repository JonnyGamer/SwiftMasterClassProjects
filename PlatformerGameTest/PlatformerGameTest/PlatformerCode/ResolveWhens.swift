//
//  ResolveWhens.swift
//  PlatformerGameTest
//
//  Created by Jonathan Pappas on 4/12/21.
//

import Foundation

extension BasicSprite {
    func add(_ this: Scene) {
        guard let foo = self as? (BasicSprite & Spriteable) else { return }
        
        for i in foo.specificActions {
            foo.resolveWhen(this, foo, i)
        }
    }
    
}

extension BasicSprite {

    func resolveWhen(_ this: Scene,_ foo: (BasicSprite & Spriteable),_ when: When) {
        
        if let foo = foo as? MovableSprite {
            
            switch when {
            case .jumpWhen(let userAction): resolveUserAction(this, userAction, foo.jump)
            case .moveLeftWhen(let userAction): resolveUserAction(this, userAction, {foo.move(.left)})
            case .moveRightWhen(let userAction): resolveUserAction(this, userAction, {foo.move(.right)})
            case .fallWhen(let userAction): resolveUserAction(this, userAction, foo.fall)
            case .standWhen(let userAction): resolveUserAction(this, userAction, foo.stand)
            case .xSpeed(let n, let fps): foo.xSpeed = n; foo.everyFrame = fps
            case .reverseDirection(let userAction): resolveUserAction(this, userAction, { foo.xSpeed *= -1 })
            case .die(let userAction): resolveUserAction(this, userAction, { foo.die(nil) })
            default: break
            }
            
        }
            
            switch when {
                
            case .bounceObjectWhen(let userAction): resolveUserActionSPRITE(this, userAction, { $0.jump((foo as? Trampoline)?.bounciness) })
                
            case .stopObjectFromMoving(let dir, when: let userAction): resolveUserActionSPRITE(this, userAction, { $0.stopMoving(self, dir) })
            case .allowObjectToPush(let dir, when: let userAction): resolveUserActionSPRITE(this, userAction, { $0.pushDirection(self, dir) })
            case .killObject(let dir, let userAction): resolveUserActionSPRITE(this, userAction, { $0.die(dir) })
                
            default: break
            }
        
        
        
    }
    
    func resolveUserActionSPRITE(_ this: Scene,_ userAction: UserAction,_ action: @escaping (MovableSprite) -> ()) {
        switch userAction {
        case .thisBumped(let dir):
            switch dir {
            case .up:
                print("OK")
                print(bumpedFromTop.count)
                bumpedFromTop.append(action)
                print(bumpedFromTop.count)
            case .down: bumpedFromBottom.append(action)
            case .left: bumpedFromLeft.append(action)
            case .right: bumpedFromRight.append(action)
            }
            
//        case .yPositionIsLessThanZeroThenSetPositionToZero:
//            this.annoyance.append {
//                if self.position.y < 0 {
//                    self.position.y = 0
//                    self.stopMoving(.down)
//                }
//            }
            
        default: fatalError()
        }
    }
    
    func resolveUserAction(_ this: Scene,_ userAction: UserAction,_ action: @escaping () -> ()) {
        switch userAction {
        case .pressedButton(let button):
            switch button {
            case .jump: this.doThisWhenJumpButtonIsPressed.append(action)
            case .left: this.doThisWhenLeftButtonIsPressed.append(action)
            case .right: this.doThisWhenRightButtonIsPressed.append(action)
            }
            
        case .onLedge:
            (self as? MovableSprite)?.standingOnLedgeAction.append(action)

        case .neitherLeftNorRightButtonsAreBeingClicked:
            this.doThisWhenStanding.append(action)
            
        case .notOnGround: break
            
        case .always:
            annoyance.append(action)
            
        case .playerIsLeftOfSelf:
            annoyance.append {
                if this.players.allSatisfy({ $0.midX < self.midX }) {
                    action()
                }
            }
        case .playerIsRightOfSelf:
            annoyance.append {
                if this.players.allSatisfy({ self.midX < $0.midX }) {
                    action()
                }
            }
        case .playerHasSameXPositionAsSelf:
            annoyance.append {
                if this.players.allSatisfy({ self.midX == $0.midX }) {
                    action()
                }
            }
        case .thisBumped(let dir):
            if dir == .left {
                (self as? MovableSprite)?.runWhenBumpLeft.append(action)
            } else if dir == .right {
                (self as? MovableSprite)?.runWhenBumpRight.append(action)
            } else if dir == .down {
                (self as? MovableSprite)?.runWhenBumpDown.append(action)
            } else if dir == .up {
                (self as? MovableSprite)?.runWhenBumpUp.append(action)
            }
        
        default: fatalError()
        }
    }
}

extension Array where Element == () -> () {
    func run() {
        forEach { $0() }
    }
}

