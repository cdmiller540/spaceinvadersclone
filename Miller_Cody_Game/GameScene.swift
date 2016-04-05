//
//  GameScene.swift
//  Miller_Cody_Game
//
//  Created by Cody Miller on 11/17/15.
//  Copyright (c) 2015 Cody Miller. All rights reserved.
//
import SpriteKit
import AVFoundation
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let invader   : UInt32 = 0b1       // 1
    static let laserbeam: UInt32 = 0b10      // 2
    static let player1: UInt32 = 0b11
    static let largeInvader: UInt32 = 0b100
    
}
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    var score = 0
    var multiplier = 1
    var level = 1
    var health = 5
    var music = AVAudioPlayer()
    var sound = AVAudioPlayer()
    let musicPath = NSBundle.mainBundle().pathForResource("title_screen", ofType: "mp3")
    let soundPath = NSBundle.mainBundle().pathForResource("pew-pew-lei", ofType: "caf")
    let scoreLabel = SKLabelNode()
    let healthLabel = SKLabelNode()
    let multiplierLabel = SKLabelNode()
    var invaderHealth = 0
    var MAX_SCORE = 30
    var didWin = false
    var gameOver = false
    var win = false
    var gameOverPopUp = SKSpriteNode()
    var gameOverTexture = SKTexture(imageNamed: "book.png")
    var invaders:[SKSpriteNode] = []
    
    // 1
    let player1 = SKSpriteNode(imageNamed: "player1")
    
    
    override func didMoveToView(view: SKView) {
        if level == 1{
        resetGame();
        }
        else{
            playLevel2()
        }
    }
    func resetGame(){
        score = 0
        gameOver = false
        health = 5
        MAX_SCORE = 30
        player1.physicsBody = SKPhysicsBody(rectangleOfSize: (player1.size)) // 1
        player1.physicsBody?.dynamic = true // 2
        player1.physicsBody?.categoryBitMask = PhysicsCategory.player1 // 3
        player1.physicsBody?.contactTestBitMask = PhysicsCategory.invader // 4
        player1.physicsBody?.collisionBitMask = PhysicsCategory.None
        backgroundColor = SKColor.blackColor()
        // 3
        addScore()
        //addHealth()
        player1.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4
        addChild(player1)
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addinvader),
                SKAction.waitForDuration(1.0)
                ])
            ))
        playMusic()
    }
    func playLevel2(){
        score = 0
        gameOver = false
        health = 5
        MAX_SCORE = 100
        
        player1.physicsBody = SKPhysicsBody(rectangleOfSize: (player1.size)) // 1
        player1.physicsBody?.dynamic = true // 2
        player1.physicsBody?.categoryBitMask = PhysicsCategory.player1 // 3
        player1.physicsBody?.contactTestBitMask = PhysicsCategory.invader // 4
        player1.physicsBody?.collisionBitMask = PhysicsCategory.None
        backgroundColor = SKColor.blackColor()
        // 3
        addScore()
       // addHealth()
        player1.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // 4
        addChild(player1)
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        createLargeInvader()
        playMusic()
        
    }
    func playMusic()
    {
        do
        {
            try music = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: musicPath!))
            music.play()
        }
        catch
        {
            print("Something really bad happened")
        }
    }
    func playSound(){
        do
        {
            try sound = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: soundPath!))
            sound.play()
        }
        catch
        {
            print("Something really bad happened")
        }
    }
    func createLargeInvader(){
        invaderHealth = 100
        let largeInvader = SKSpriteNode(imageNamed: "largeInvader")
        largeInvader.physicsBody = SKPhysicsBody(rectangleOfSize: (largeInvader.size)) // 1
        largeInvader.physicsBody?.dynamic = true // 2
        largeInvader.physicsBody?.categoryBitMask = PhysicsCategory.largeInvader // 3
        largeInvader.physicsBody?.contactTestBitMask = PhysicsCategory.laserbeam // 4
        largeInvader.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        let pointY = CGFloat(frame.height/2);
        largeInvader.position = CGPoint(x: size.width + largeInvader.size.width/2, y: pointY)
        // Add the invader to the scene
        addChild(largeInvader)
        
        // Determine speed of the invader
        let actualDuration = 30.0
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -largeInvader.size.width/2, y: pointY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        largeInvader.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func addScore()
    {
        scoreLabel.fontName = "Comic Sans"
        scoreLabel.fontSize = 30
        scoreLabel.text = "Score: " + String(score) + " Health: " + String(health)
        
        let xCoord = CGRectGetMidX(self.frame)
        let yCoord = CGRectGetMaxY(self.frame) - 55
        scoreLabel.position = CGPoint(x: xCoord, y: yCoord)
        
        self.addChild(scoreLabel)
        /*healthLabel.fontName = "Comic Sans"
        healthLabel.fontSize = 30
        healthLabel.text = "Health: " + String(health)
        
        let xCord = CGRectGetMaxX(self.frame) - 40
        let yCord = CGRectGetMaxY(self.frame) - 55
        scoreLabel.position = CGPoint(x:0,y:0)
        self.addChild(healthLabel)*/
        
        
        
    }
    func addHealth(){
        healthLabel.fontName = "Comic Sans"
        healthLabel.fontSize = 30
        healthLabel.text = String(health)
        
        let xCord = CGRectGetMaxX(self.frame) - 40
        let yCord = CGRectGetMaxY(self.frame) - 55
        scoreLabel.position = CGPoint(x:0,y:0)
        self.addChild(healthLabel)
    }
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addinvader() {
        
        // Create sprite
        let invader = SKSpriteNode(imageNamed: "invader")
        invader.physicsBody = SKPhysicsBody(rectangleOfSize: (invader.size)) // 1
        invader.physicsBody?.dynamic = true // 2
        invader.physicsBody?.categoryBitMask = PhysicsCategory.invader // 3
        invader.physicsBody?.contactTestBitMask = PhysicsCategory.laserbeam // 4
        invader.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        // Determine where to spawn the invader along the Y axis
        let actualY = random(min: invader.size.height/2, max: size.height - invader.size.height/2)
        
        // Position the invader slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        invader.position = CGPoint(x: size.width + invader.size.width/2, y: actualY)
        invaders.append(invader)
        // Add the invader to the scene
        addChild(invader)
        
        // Determine speed of the invader
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -invader.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        invader.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !gameOver{
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of laserbeam
        let laserbeam = SKSpriteNode(imageNamed: "laserbeam")
        laserbeam.position = player1.position
        
        // 3 - Determine offset of location to laserbeam
        let offset = touchLocation - laserbeam.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(laserbeam)
        laserbeam.physicsBody = SKPhysicsBody(circleOfRadius: laserbeam.size.width/2)
        laserbeam.physicsBody?.dynamic = true
        laserbeam.physicsBody?.categoryBitMask = PhysicsCategory.laserbeam
        laserbeam.physicsBody?.contactTestBitMask = PhysicsCategory.invader
        laserbeam.physicsBody?.collisionBitMask = PhysicsCategory.None
        laserbeam.physicsBody?.usesPreciseCollisionDetection = true
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + laserbeam.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        laserbeam.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        playSound()
        }
        else{
            // Determine where they clicked (thumbs up or down)
            let touch = touches.first
            let location = touch?.locationInNode(self)
            let touchedNode = nodeAtPoint(location!)
            
            if touchedNode.name == "yes"
            {
                print("yes")
                self.removeAllChildren()
                if (win == true && level == 1){
                playLevel2()
                    level = 2
                }
                else if(win == true && level == 2){
                    resetGame()
                    level = 1
                    
                }
                else{
                    resetGame()
                    level = 1
                }
            }
            else if touchedNode.name == "no"
            {
                print("no")
            }
            else
            {
                print("something else")
            }
        }
        }
    
    
    func laserbeamDidCollideWithinvader(laserbeam:SKSpriteNode, invader:SKSpriteNode) {
        print("Hit")
        ++score
        print(score)
        laserbeam.removeFromParent()
        invader.removeFromParent()
    }
    func invaderDidCollideWithplayer1(player1:SKSpriteNode, invader: SKSpriteNode){
        print("You've been hit")
        invader.removeFromParent()
        if (health == 1){
            gameover(false);
        }
        else{
            health = health - 1;
        }
    }
    func gameover(win: Bool){
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
        let obj1 = firstNode.physicsBody
        let obj2 = secondNode.physicsBody
        
        
        if ((obj1?.categoryBitMask == PhysicsCategory.laserbeam && obj2?.categoryBitMask == PhysicsCategory.invader)   || ( obj1?.categoryBitMask == PhysicsCategory.invader && obj2?.categoryBitMask == PhysicsCategory.laserbeam))
        {
            print("got em!")
            ++score
            print(score)
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
        else if ((obj1?.categoryBitMask == PhysicsCategory.laserbeam && obj2?.categoryBitMask == PhysicsCategory.largeInvader)   || ( obj1?.categoryBitMask == PhysicsCategory.largeInvader && obj2?.categoryBitMask == PhysicsCategory.laserbeam))
        {
            print("got em!")
            ++score
            print(score)
            --invaderHealth;
            if(obj1?.categoryBitMask == PhysicsCategory.laserbeam){
                firstNode.removeFromParent()
            }
            else{
                secondNode.removeFromParent()
            }
        }
        
        else if ((obj1?.categoryBitMask == PhysicsCategory.largeInvader && obj2?.categoryBitMask == PhysicsCategory.player1)   || ( obj1?.categoryBitMask == PhysicsCategory.player1 && obj2?.categoryBitMask == PhysicsCategory.largeInvader))
        {
            print("got em!")
            ++score
            print(score)
            health = 0
            if(obj1?.categoryBitMask == PhysicsCategory.laserbeam){
                firstNode.removeFromParent()
            }
            else{
                secondNode.removeFromParent()
            }
        }
        

        else if (
            (obj1?.categoryBitMask == PhysicsCategory.player1 && obj2?.categoryBitMask == PhysicsCategory.invader)   ||
                ( obj1?.categoryBitMask == PhysicsCategory.invader && obj2?.categoryBitMask == PhysicsCategory.player1))
        {
            print("He got me!")
            print(health)
            --health
            
            if obj1?.categoryBitMask == PhysicsCategory.player1
            {
                let pos = secondNode.position
                secondNode.removeFromParent()
                firstNode.position = pos
            }
            else
            {
                let pos = firstNode.position
                firstNode.removeFromParent()
                secondNode.position = pos
                
            }
        }
        else if (
            (obj1?.categoryBitMask == PhysicsCategory.invader && obj2?.categoryBitMask == PhysicsCategory.largeInvader)   ||
                ( obj1?.categoryBitMask == PhysicsCategory.largeInvader && obj2?.categoryBitMask == PhysicsCategory.invader))
        {
            
            
            if obj1?.categoryBitMask == PhysicsCategory.invader
            {
                firstNode.removeFromParent()
            }
            else
            {
                secondNode.removeFromParent()
                
            }
        }
        // ends detection of player vs. bully
        scoreLabel.text = "Score: " + String(score) + " Health: " + String(health) 
        //healthLabel.text = "Health: " + String(health)
        
        var winMsg = ""
        if score >= MAX_SCORE
        {
            print("you win")
            win = true
            gameOver = true
            winMsg = "You Won!!!!!!!"
            
        }
        else if health <= 0
        {
            print("you lost")
            winMsg = "You LOST!!!!!"
            win = false
            gameOver = true
        }
        
        //check to see if game is over
        if gameOver
        {
            var winLabel = SKLabelNode()
            winLabel.text = winMsg
            winLabel.fontColor = UIColor.redColor()
            winLabel.fontSize = 40
            winLabel.fontName = "Comic Sans"
            winLabel.position = CGPoint(x: scoreLabel.position.x, y: scoreLabel.position.y - 30)
            self.addChild(winLabel)
            doGameOver()
            // if so
            // pause the action
            // display a pop up
        }
        
        
        
    } // ends if not contacting the floor
//end did begin contact

func doGameOver()
{
    // pause the action
    // display a pop up
    music.stop()
    self.physicsWorld.contactDelegate = nil
    self.removeChildrenInArray(invaders)
    gameOverPopUp = SKSpriteNode(texture: gameOverTexture)
    gameOverPopUp.size.width = self.frame.size.width/2
    gameOverPopUp.size.height = self.frame.size.height/4
    gameOverPopUp.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
    gameOverPopUp.zPosition = 50
    self.addChild(gameOverPopUp)
    
    let xCoord = CGRectGetMidX(gameOverPopUp.frame)
    let yCoord = CGRectGetMidY(gameOverPopUp.frame)
    if (win == true && level == 1) {
    let ins = SKLabelNode()
    ins.text = "Play Level 2?"
    ins.fontName = "i have no clue"
    ins.fontColor = UIColor.redColor()
    ins.fontSize = 40
    ins.zPosition = 51
    ins.position = CGPoint(x:xCoord, y: yCoord + 20)
    self.addChild(ins)
    
    let yes = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-up.png"))
    yes.zPosition = 51
    yes.position = CGPoint(x: xCoord - 125, y: yCoord - 50)
    yes.size = CGSize(width: 50, height: 50)
    yes.name = "yes"
    self.addChild(yes)
    
    let no = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-down.png"))
    no.zPosition = 51
    no.position = CGPoint(x: xCoord + 125, y: yCoord - 50)
    no.size = CGSize(width: 50, height: 50)
    no.name = "no"
    self.addChild(no)

}
    else if(win == true && level == 2){
        let ins = SKLabelNode()
        ins.text = "You beat the game. Play again?"
        ins.fontName = "i have no clue"
        ins.fontColor = UIColor.redColor()
        ins.fontSize = 40
        ins.zPosition = 51
        ins.position = CGPoint(x:xCoord, y: yCoord + 20)
        self.addChild(ins)
        
        let yes = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-up.png"))
        yes.zPosition = 51
        yes.position = CGPoint(x: xCoord - 125, y: yCoord - 50)
        yes.size = CGSize(width: 50, height: 50)
        yes.name = "yes"
        self.addChild(yes)
        
        let no = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-down.png"))
        no.zPosition = 51
        no.position = CGPoint(x: xCoord + 125, y: yCoord - 50)
        no.size = CGSize(width: 50, height: 50)
        no.name = "no"
        self.addChild(no)
    }
    else{
        let ins = SKLabelNode()
        ins.text = "Play again?"
        ins.fontName = "i have no clue"
        ins.fontColor = UIColor.redColor()
        ins.fontSize = 40
        ins.zPosition = 51
        ins.position = CGPoint(x:xCoord, y: yCoord + 20)
        self.addChild(ins)
        
        let yes = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-up.png"))
        yes.zPosition = 51
        yes.position = CGPoint(x: xCoord - 125, y: yCoord - 50)
        yes.size = CGSize(width: 50, height: 50)
        yes.name = "yes"
        self.addChild(yes)
        
        let no = SKSpriteNode(texture: SKTexture(imageNamed: "thumb-down.png"))
        no.zPosition = 51
        no.position = CGPoint(x: xCoord + 125, y: yCoord - 50)
        no.size = CGSize(width: 50, height: 50)
        no.name = "no"
        self.addChild(no)

    }
    
    
}


    }

