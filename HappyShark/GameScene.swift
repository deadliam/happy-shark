//
//  GameScene.swift
//  HappyShark
//
//  Created by Anatolii Kasianov on 24.09.2020.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let enemyFish : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
}

//func +(left: CGPoint, right: CGPoint) -> CGPoint {
//  return CGPoint(x: left.x + right.x, y: left.y + right.y)
//}
//
//func -(left: CGPoint, right: CGPoint) -> CGPoint {
//  return CGPoint(x: left.x - right.x, y: left.y - right.y)
//}
//
//func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
//  return CGPoint(x: point.x * scalar, y: point.y * scalar)
//}
//
//func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
//  return CGPoint(x: point.x / scalar, y: point.y / scalar)
//}
//
//#if !(arch(x86_64) || arch(arm64))
//  func sqrt(a: CGFloat) -> CGFloat {
//    return CGFloat(sqrtf(Float(a)))
//  }
//#endif
//
//extension CGPoint {
//  func length() -> CGFloat {
//    return sqrt(x*x + y*y)
//  }
//
//  func normalized() -> CGPoint {
//    return self / length()
//  }
//}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "fishShark.png")
    
    let backgroundTexture = SKTexture(imageNamed: "background")
    let groundTexture = SKTexture(imageNamed: "sand")
    
    let sound = SKAction.playSoundFileNamed("sound.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.gray
        player.position = CGPoint(x: size.width / 2 + 400, y: size.height / 2)
        addChild(player)
        
        createBackground()
        createGroundLayer()

        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addBubbles),
                SKAction.wait(forDuration: 2.0)
            ])
        ))

        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemyFish),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPosition = (touches.first?.location(in: self))!
        player.position = CGPoint(x: player.position.x, y: touchPosition.y)
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(sound)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    func addEnemyFish() {
        let enemyFish = SKSpriteNode(imageNamed: "orangeFish.png")
        let actualY = random(min: enemyFish.size.height / 2, max: size.height - enemyFish.size.height / 2)
        enemyFish.position = CGPoint(x: enemyFish.size.width / 2, y: actualY)
        addChild(enemyFish)

        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))

        let actionMove = SKAction.move(to: CGPoint(x: size.width + enemyFish.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
          
        let actionMoveDone = SKAction.removeFromParent()
        enemyFish.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func createBackground() {
        let background = SKSpriteNode(texture: backgroundTexture)
        background.zPosition = -30
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: 0.5, y: 0)
        addChild(background)

//        for i in 0 ... 1 {
//            let background = SKSpriteNode(texture: backgroundTexture)
//            background.zPosition = -30
//            background.anchorPoint = CGPoint.zero
//            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
//            addChild(background)
//        }
    }
    
    func addBubbles() {
        let bubble = SKSpriteNode(imageNamed: "bubble.png")
        let bubbleSize = random(min: CGFloat(20.0), max: CGFloat(80))
        let actualX = random(min: bubble.size.width / 2 - size.width / 2, max: size.width - bubble.size.width / 2)

        bubble.position = CGPoint(x: actualX, y: bubble.size.height / 2)
        bubble.scale(to: CGSize(width: bubbleSize, height: bubbleSize))
        addChild(bubble)

        let actualDurationV = random(min: CGFloat(3.0), max: CGFloat(10.0))
        
        let actionMoveVertical = SKAction.move(to: CGPoint(x: actualX, y: size.height + bubble.size.height / 2), duration: TimeInterval(actualDurationV))
        
        let actionMoveHorizontal = SKAction.move(to: CGPoint(x: actualX + size.width / 2 + bubble.size.width / 2, y: size.height + bubble.size.height / 2), duration: TimeInterval(5))
        
        let actionMoveDone = SKAction.removeFromParent()
        bubble.run(SKAction.sequence([actionMoveVertical, actionMoveHorizontal]))
        bubble.run(SKAction.sequence([actionMoveHorizontal, actionMoveDone]))
    }
    
    func createGround() {

        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 - (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)

            addChild(ground)

            let moveRight = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 25)
            let moveReset = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveRight, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)

            ground.run(moveForever)
        }
    }
    
    func createCastleGround() {
        let castle = SKSpriteNode(imageNamed: "sandCastle")
        let actualY = castle.size.height / 2 - 110
        
//        castle.zPosition = -20
        castle.position = CGPoint(x: 0, y: actualY)
        castle.scale(to: CGSize(width: 300, height: 300))
        addChild(castle)

        let actualDuration = CGFloat(12.5)
        let actionMove = SKAction.move(to: CGPoint(x: size.width, y: actualY), duration: TimeInterval(actualDuration))
          
        let actionMoveDone = SKAction.removeFromParent()
        castle.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func createStar() {
        let star = SKSpriteNode(imageNamed: "star")
        let actualY = star.size.height / 2
        
//        castle.zPosition = -20
        star.position = CGPoint(x: 0, y: actualY)
//        star.scale(to: CGSize(width: 300, height: 300))
        addChild(star)

        let actualDuration = CGFloat(12.5)
        let actionMove = SKAction.move(to: CGPoint(x: size.width, y: actualY), duration: TimeInterval(actualDuration))
          
        let actionMoveDone = SKAction.removeFromParent()
        star.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func createGroundLayer() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 5),
                SKAction.run(createCastleGround),
                SKAction.wait(forDuration: 9.0)
            ])
        ))
                                
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(createStar),
                SKAction.wait(forDuration: 28.0)
            ])
        ))
        
        createGround()
    }
}
