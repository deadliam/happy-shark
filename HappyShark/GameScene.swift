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

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundMusic: SKAudioNode!
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var scoreLabel: SKLabelNode!
    
    var player: SKSpriteNode!
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var gameState = GameState.showingLogo
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }

    let backgroundTexture = SKTexture(imageNamed: "background")
    let groundTexture = SKTexture(imageNamed: "sand")
    
//    let sound = SKAction.playSoundFileNamed("bensound-ukulele.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        if let musicURL = Bundle.main.url(forResource: "bensound-ukulele", withExtension: "wav") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
        createPlayer()
        createLogos()
        
        createScore()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.gray
        
        createBackground()
        createGroundLayer()

        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addBubbles),
                SKAction.wait(forDuration: 2.0)
            ])
        ))
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
        switch gameState {
        case .showingLogo:
            gameState = .playing

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startEnemies()
            }

            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)

        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))

        case .dead:
            break
        }
    }

//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered
//        let value = player.physicsBody!.velocity.dy * 0.001
//        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
//        player.run(rotate)
//    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "fishShark.png")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: size.width / 2 + 400, y: size.height / 2)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = true
//        player.physicsBody?.collisionBitMask = 0
        
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "fishShark.png")
        let frame3 = SKTexture(imageNamed: "fishShark.png")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)

        player.run(runForever)
    }
    
    func startEnemies() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemyFish),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
    }
    
    func addEnemyFish() {
        let enemyFishTexture = SKTexture(imageNamed: "orangeFish.png")
        let enemyFish = SKSpriteNode(texture: enemyFishTexture)
        let actualY = random(min: enemyFish.size.height / 2, max: size.height - enemyFish.size.height / 2)
        enemyFish.position = CGPoint(x: enemyFish.size.width / 2, y: actualY)
        
        enemyFish.physicsBody = SKPhysicsBody(texture: enemyFishTexture, size: enemyFishTexture.size())
        enemyFish.physicsBody?.isDynamic = false
        
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
            
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)

            let moveRight = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 25)
            let moveReset = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveRight, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)

            ground.run(moveForever)
        }
    }
    
    func createCastleGround() {
        let castleTexture = SKTexture(imageNamed: "sandCastle")
        let castle = SKSpriteNode(texture: castleTexture)
        let actualY = castle.size.height / 2 - 110
        
//        castle.zPosition = -20
        castle.position = CGPoint(x: 0, y: actualY)
        castle.scale(to: CGSize(width: 300, height: 300))
        
        castle.physicsBody = SKPhysicsBody(texture: castleTexture, size: castleTexture.size())
        castle.physicsBody?.isDynamic = false
        
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
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24

        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black

        addChild(scoreLabel)
    }
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "Netflix-1")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)

        gameOver = SKSpriteNode(imageNamed: "Netflix-1")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
}
