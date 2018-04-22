////
////  GameViewController.swift
////  HCCCARPong
////
////  Created by Samuel Folledo on 4/22/18.
////  Copyright © 2018 Samuel Folledo. All rights reserved.
////
//
//import SpriteKit
//import GameplayKit
//
//let BallCategoryName = "ball"
//let PaddleCategoryName = "paddle"
//let BlockCategoryName = "block"
//let GameMessageName = "gameMessage"
//
//let BallCategory   : UInt32 = 0x1 << 0
//let BottomCategory : UInt32 = 0x1 << 1
//let BlockCategory  : UInt32 = 0x1 << 2
//let PaddleCategory : UInt32 = 0x1 << 3
//let BorderCategory : UInt32 = 0x1 << 4
//
//
//class GameScene: SKScene, SKPhysicsContactDelegate {
//    
//    var isFingerOnPaddle = false
//    
//    //gameState
//    //lazy var gameState: GKStateMachine = GKStateMachine(states: [ WaitingForTap(scene: self), Playing(scene: self), GameOver(scene: self)])
//    
//    //gameWon
//    //var gameWon: Bool = false{
////        didSet{
////            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
////            let textureName = gameWon ? "YouWon" : "GameOver"
////            let texture = SKTexture(imageNamed: textureName)
////            let actionSequence = SKAction.sequence([SKAction.setTexture(texture), SKAction.scale(to: 1.0, duration: 0.25)])
////
////            gameOver.run(actionSequence)
////            run(gameWon ? gameWonSound : gameOverSound)
////        }
////    }
////
////    //sounds
////    let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
////    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
////    let bambooBreakSound = SKAction.playSoundFileNamed("BambooBreak", waitForCompletion: false)
////    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
////    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
////
//    
//    //didMove
//    override func didMove(to view: SKView) {
//        
//        //borders
//        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        borderBody.friction = 0
//        self.physicsBody = borderBody
//        
//        //physicsWorld
//        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
//        physicsWorld.contactDelegate = self
//        
//        //ball
//        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
//        //        ball.physicsBody!.applyImpulse(CGVector(dx: 2.5, dy: -2.5))
//        
//        //bottom of the screen
//        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
//        let bottom = SKNode()
//        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
//        addChild(bottom)
//        
//        //paddles
//        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
//        
//        //category bit mask
//        bottom.physicsBody!.categoryBitMask = BottomCategory
//        ball.physicsBody!.categoryBitMask = BallCategory
//        paddle.physicsBody!.categoryBitMask = PaddleCategory
//        borderBody.categoryBitMask = BorderCategory
//        
//        //detects collisions between BALL and BOTTOMRECT
//        ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory | BorderCategory | PaddleCategory
//        
//        //blocks
//        let numberOfBlocks = 8
//        let blockWidth = SKSpriteNode(imageNamed: "block").size.width
//        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
//        let xOffset = (frame.width - totalBlocksWidth) / 2
//        
//        for i in 0 ..< numberOfBlocks {
//            let block = SKSpriteNode(imageNamed: "block.png")
//            block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth, y: frame.height * 0.8)
//            
//            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
//            block.physicsBody!.allowsRotation = false
//            block.physicsBody!.friction = 0.0
//            block.physicsBody!.affectedByGravity = false
//            block.physicsBody!.isDynamic = false
//            block.name = BlockCategoryName
//            block.physicsBody!.categoryBitMask = BlockCategory
//            block.zPosition = 2
//            addChild(block)
//        }
//        
//        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
//        gameMessage.name = GameMessageName
//        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
//        gameMessage.zPosition = 4
//        gameMessage.setScale(0.0)
//        addChild(gameMessage)
//        
//        let trailNode = SKNode()
//        trailNode.zPosition = 1
//        addChild(trailNode)
//        let trail = SKEmitterNode(fileNamed: "BallTrail")!
//        trail.targetNode = trailNode
//        ball.addChild(trail)
//        
//        gameState.enter(WaitingForTap.self)
//        
//    } //end of didMove
//    
//    //didBegin
//    func didBegin(_ contact: SKPhysicsContact) {
//        if gameState.currentState is Playing {
//            var firstBody: SKPhysicsBody
//            var secondBody: SKPhysicsBody
//            
//            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
//                firstBody = contact.bodyA
//                secondBody = contact.bodyB
//            } else {
//                firstBody = contact.bodyB
//                secondBody = contact.bodyA
//            }
//            
//            //ball and bottom
//            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
//                
//                gameState.enter(GameOver.self)
//                gameWon = false
//                //print("Hit bottom. First contact has been made")
//            }
//            
//            //ball and block
//            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory{
//                //run the broken sks
//                breakBlock(node: secondBody.node!)
//                //runs the func isGameWon
//                if isGameWon(){
//                    gameState.enter(GameOver.self)
//                    gameWon = true
//                }
//            }
//            
//            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
//                run(blipSound)
//            }
//            if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
//                run(blipPaddleSound)
//            }
//        } //end of if Playing
//    } //end of didBegin
//    
//    
//    func breakBlock(node: SKNode){
//        run(bambooBreakSound)
//        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
//        particles.position = node.position
//        particles.zPosition = 3
//        addChild(particles)
//        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent() ]))
//        node.removeFromParent()
//        
//    }
//    
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        switch gameState.currentState {
//        case is WaitingForTap:
//            gameState.enter(Playing.self)
//            isFingerOnPaddle = true
//            
//        case is Playing:
//            let touch = touches.first
//            let touchLocation = touch!.location(in: self)
//            
//            if let body = physicsWorld.body(at: touchLocation) {
//                if body.node!.name == PaddleCategoryName {
//                    //    print ("Began touch on paddle")
//                    isFingerOnPaddle = true
//                }
//            }
//            
//        case is GameOver:
//            let newScene = GameScene(fileNamed: "GameScene")
//            newScene!.scaleMode = .aspectFit
//            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//            self.view?.presentScene(newScene!, transition: reveal)
//            
//        default:
//            break
//        }
//    }
//    
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        if isFingerOnPaddle {
//            let touch = touches.first
//            let touchLocation = touch!.location(in: self)
//            let previousLocation = touch!.previousLocation(in: self)
//            
//            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
//            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
//            paddleX = max(paddleX, paddle.size.width / 2)
//            paddleX = min(paddleX, size.width - paddle.size.width / 2)
//            
//            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
//        }
//    }
//    
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isFingerOnPaddle = false
//    }
//    
//    
//    override func update(_ currentTime: TimeInterval) {
//        gameState.update(deltaTime: currentTime)
//    }
//    
//    
//    func isGameWon() -> Bool{
//        var numberOfBricks = 0
//        self.enumerateChildNodes(withName: BlockCategoryName){
//            node, stop in
//            numberOfBricks = numberOfBricks + 1
//        }
//        return numberOfBricks == 0
//    }
//    
//    
//    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
//        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
//        return (rand) * (to - from) + from
//    }
//    
//}
//
