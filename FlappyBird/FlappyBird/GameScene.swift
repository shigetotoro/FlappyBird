//
//  GameScene.swift
//  FlappyBird
//
//  Created by 森重翔平 on 2017/04/23.
//  Copyright © 2017年 森重翔平. All rights reserved.
//

import SpriteKit
import AVFoundation

class gameScene: SKScene, SKPhysicsContactDelegate {
  
  var scrollNode:SKNode!
  var wallNode:SKNode!
  var bird:SKSpriteNode!
  var item:SKNode!
  
  let birdCategory: UInt32 = 1 << 0
  let groundCategory: UInt32 = 1 << 1
  let wallCategory: UInt32 = 1 << 2
  let scoreCategory: UInt32 = 1 << 3
  let itemCategory: UInt32 = 1 << 4
  
  var score = 0
  var scoreLabelNode:SKLabelNode!
  var bestScoreLabelNode:SKLabelNode!
  var itemscore = 0
  var itemscoreLabelNode:SKLabelNode!
  var bestitemscoreLabelNode:SKLabelNode!
  let userDefaults:UserDefaults = UserDefaults.standard
  
  var player:AVAudioPlayer!
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if scrollNode.speed > 0 {
    
    bird.physicsBody?.velocity = CGVector.zero
    
    bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
  } else if bird.speed == 0 {
      restart()
  }
  }

  override func didMove(to view: SKView) {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
    physicsWorld.contactDelegate = self
    
    backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
    

    
    
    scrollNode = SKNode()
    addChild(scrollNode)
    
    
    wallNode = SKNode()
    scrollNode.addChild(wallNode)
    
    item = SKNode()
    scrollNode.addChild(item)
    
    setupGround()
    setupCloud()
    setupWall()
    setupBird()
    setupItem()
    
    
    setupScoreLabel()
  }
  
  func setupGround() {
  
    let groundTexture = SKTexture(imageNamed: "ground")
    groundTexture.filteringMode = SKTextureFilteringMode.nearest
    
    let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
    
    let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5.0)
    
    let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
    
    let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
    
    stride(from: 0.0, to: needNumber, by: 1.0).forEach { i in
      let sprite = SKSpriteNode(texture: groundTexture)
      
      sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
      
      sprite.run(repeatScrollGround)
      
      sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
      
      sprite.physicsBody?.categoryBitMask = groundCategory
      
      sprite.physicsBody?.isDynamic = false
      
      sprite.physicsBody?.isDynamic = false
      
      scrollNode.addChild(sprite)
      }
    }
    
    func setupCloud() {
      
      let cloudTexture = SKTexture(imageNamed: "cloud")
      cloudTexture.filteringMode = SKTextureFilteringMode.nearest
      
      let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
      
      let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
      
      let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
      
      let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
      
      stride(from: 0.0, to: needCloudNumber, by: 1.0).forEach { i in
        let sprite = SKSpriteNode(texture: cloudTexture)
        sprite.zPosition = -100
        
        sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
        
        sprite.run(repeatScrollCloud)
        
        scrollNode.addChild(sprite)
      }
    }
    


    func setupWall() {
      
      let wallTexture = SKTexture(imageNamed: "wall")
      wallTexture.filteringMode = SKTextureFilteringMode.linear
      
      let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
      
      let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4.0)
      
      let removeWall = SKAction.removeFromParent()
      
      let wallAnimation = SKAction.sequence([moveWall, removeWall])
      
      let createWallAnimation = SKAction.run({
        
        let wall = SKNode()
        wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
        wall.zPosition = -50.0
        
        let center_y = self.frame.size.height / 2
        
        let random_y_range = self.frame.size.height / 4
        
        let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2)
        
        let random_y = arc4random_uniform( UInt32(random_y_range) )
        
        let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
        
        let slit_lenght = self.frame.size.height / 6
        
        let under = SKSpriteNode(texture: wallTexture)
        under.position = CGPoint(x: 0.0, y: under_wall_y)
        wall.addChild(under)
        
        under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
        under.physicsBody?.categoryBitMask = self.wallCategory
        
        under.physicsBody?.isDynamic = false
        
        let upper = SKSpriteNode(texture: wallTexture)
        upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_lenght)
        
        upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
        upper.physicsBody?.categoryBitMask = self.wallCategory
        
        upper.physicsBody?.isDynamic = false
        
        wall.addChild(upper)
        
        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
        
        wall.addChild(scoreNode)
        
        wall.run(wallAnimation)
        
        self.wallNode.addChild(wall)
      })
      
      let waitAnimation = SKAction.wait(forDuration: 2)
      
      let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
      
      wallNode.run(repeatForeverAnimation)
}
  func setupBird() {
    
    let birdTextureA = SKTexture(imageNamed: "bird_a")
    birdTextureA.filteringMode = SKTextureFilteringMode.linear
    let birdTextureB = SKTexture(imageNamed: "bird_b")
    birdTextureB.filteringMode = SKTextureFilteringMode.linear
    
    let texuresAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
    let flap = SKAction.repeatForever(texuresAnimation)
    
    bird = SKSpriteNode(texture: birdTextureA)
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
    
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
    
    bird.physicsBody?.allowsRotation = false
    
    bird.physicsBody?.categoryBitMask = birdCategory
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
    
    bird.run(flap)
    
    addChild(bird)
  }
  func setupItem() {
    let itemTexture = SKTexture(imageNamed: "item")
    
    let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
    
    // 画面外まで移動するアクションを作成
    let move = SKAction.moveBy(x: -movingDistance, y: 0, duration:3.0)
    
    let remove = SKAction.removeFromParent()
    
    let animation = SKAction.sequence([move, remove])
    
    
    let createAnimation = SKAction.run({
      let item = SKNode()
      item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0.0)
      item.zPosition = -40.0 // 壁より手前
      
      let center_y = self.frame.size.height / 2
      // 壁のY座標を上下ランダムにさせるときの最大値
      let random_y_range = self.frame.size.height / 4
      // 下の壁のY軸の下限
      let under_wall_lowest_y = UInt32( center_y - itemTexture.size().height / 2 -  random_y_range / 2)
      // 1〜random_y_rangeまでのランダムな整数を生成
      let random_y = arc4random_uniform( UInt32(random_y_range) )
      // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
      let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
      
      let itemNode = SKSpriteNode(texture: itemTexture)
      itemNode.position = CGPoint(x: 0.0, y: under_wall_y)
      itemNode.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
      itemNode.physicsBody?.categoryBitMask = self.wallCategory
      itemNode.physicsBody?.isDynamic = false
      item.addChild(itemNode)
      
      itemNode.physicsBody?.categoryBitMask = self.itemCategory
      itemNode.physicsBody?.contactTestBitMask = self.birdCategory
      
      
      // itemNode.position = CGPoint(x: 0.0, y: arc4random_uniform( UInt32(random_y_range) ))
      // itemNode.physicsBody = SKPhysicsBody(circleOfRadius: itemNode.size.height / 2.0)
      
      item.run(animation)
      
      self.wallNode.addChild(item)
    })
    
    // 次の壁作成までの待ち時間のアクションを作成
    let waitAnimation = SKAction.wait(forDuration: 2)
    
    // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
    let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createAnimation, waitAnimation]))
    
    wallNode.run(repeatForeverAnimation)
  }


  func setupScoreLabel() {
    score = 0
    scoreLabelNode = SKLabelNode()
    scoreLabelNode.fontColor = UIColor.black
    scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
    scoreLabelNode.zPosition = 100
    scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    scoreLabelNode.text = "Score:\(score)"
    self.addChild(scoreLabelNode)
    
    bestScoreLabelNode = SKLabelNode()
    bestScoreLabelNode.fontColor = UIColor.black
    bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
    bestScoreLabelNode.zPosition = 100
    bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    
    let bestScore = userDefaults.integer(forKey: "BEST")
    bestScoreLabelNode.text = "best Score:\(bestScore)"
    self.addChild(bestScoreLabelNode)
    
    itemscore = 0
    itemscoreLabelNode = SKLabelNode()
    itemscoreLabelNode.fontColor = UIColor.black
    itemscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
    itemscoreLabelNode.zPosition = 100 // 一番手前に表示する
    itemscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    itemscoreLabelNode.text = "ItemScore:\(score)"
    self.addChild(itemscoreLabelNode)
    
    bestitemscoreLabelNode = SKLabelNode()
    bestitemscoreLabelNode.fontColor = UIColor.black
    bestitemscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
    bestitemscoreLabelNode.zPosition = 100
    bestitemscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
    
    let bestItemScore = userDefaults.integer(forKey: "BESTITEM")
    bestitemscoreLabelNode.text = "best ItemScore:\(bestItemScore)"
    self.addChild(bestitemscoreLabelNode)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if scrollNode.speed <= 0 {
      return
      
    }
    
    if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
      print("scoreUp")
      score += 1
      scoreLabelNode.text = "Score:\(score)"
      
      var bestScore = userDefaults.integer(forKey: "BEST")
      if score > bestScore {
        bestScore = score
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        userDefaults.set(bestScore, forKey: "BEST")
        userDefaults.synchronize()
      }
    }else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory {
      contact.bodyA.node?.removeFromParent()
      print("itemscoreUp")
        itemscore += 1
        itemscoreLabelNode.text = "Item Score:\(itemscore)"
      
      var itembestscore = userDefaults.integer(forKey: "BESTITEM")
      if itemscore > itembestscore {
        itembestscore = score
        bestitemscoreLabelNode.text = "best ItemScore:\(itembestscore)"
        userDefaults.set(itembestscore, forKey: "BESTITEM")
        userDefaults.synchronize()
      }
      
      
      let action = SKAction.playSoundFileNamed("sound.mp3", waitForCompletion: false)
      //        self.run(action, withKey: "test")
      
      self.run(action)
    } else {
      
      print("GameOver")
      
      scrollNode.speed = 0
      
      bird.physicsBody?.collisionBitMask = groundCategory
      
      let roll = SKAction.rotate(byAngle: CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1)
      bird.run(roll, completion:{
        self.bird.speed = 0
      })
    }
  }
  
  
  func restart() {
    score = 0
    itemscore = 0
    scoreLabelNode.text = String("Score:\(score)")
    itemscoreLabelNode.text = "ItemScore:\(score)"
    
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
    bird.physicsBody?.velocity = CGVector.zero
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    bird.zRotation = 0.0
    
    wallNode.removeAllChildren()
    
    bird.speed = 1
    scrollNode.speed = 1
  }
  

  

class GameScene: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

}
