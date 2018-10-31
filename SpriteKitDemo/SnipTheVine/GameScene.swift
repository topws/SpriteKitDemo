
//  GameScene.swift
//  SnipTheVine

/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import AVFoundation

class GameScene: SKScene,SKPhysicsContactDelegate  {
	
	private var vineCut = false
	
  private var particles: SKEmitterNode?
	private var crocodile: SKSpriteNode!
	private var prize: SKSpriteNode!
	
	private static var backgroundMusicPlayer: AVAudioPlayer!
	
	private var sliceSoundAction: SKAction!
	private var splashSoundAction: SKAction!
	private var nomNomSoundAction: SKAction!
	private var levelOver = false
	
	let chomp = UIImpactFeedbackGenerator(style: .heavy)
	let splash = UIImpactFeedbackGenerator(style: .light)
	
  override func didMove(to view: SKView) {
    setUpPhysics()
    setUpScenery()
    setUpPrize()
    setUpVines()
    setUpCrocodile()

    setUpAudio()
  }
  
  //MARK: - Level setup
  
  fileprivate func setUpPhysics() {
    //配置物理世界
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
		physicsWorld.speed = 1.0
    
  }
  
  fileprivate func setUpScenery() {
		//注意： anchorPoint 属性使用了 unit 坐标系，(0,0) 表示子画面图片的左下角，(1,1) 表示右上角。因为量度总是为 0 到 1，所以这些坐标与图像尺寸和纵横比无关。
    let background = SKSpriteNode(imageNamed: ImageName.Background)
		background.anchorPoint = CGPoint(x: 0, y: 0)
		background.position = CGPoint(x: 0, y: 0)
		background.zPosition = Layer.Background
		background.size = CGSize(width: size.width, height: size.height)
    addChild(background)
		
		let water = SKSpriteNode(imageNamed: ImageName.Water)
		water.anchorPoint = CGPoint(x: 0, y: 0)
		water.position = CGPoint(x: 0, y: 0)
		//zPosition确保了背景保持在其它子画面的后面，前景始终在最前面绘制
		water.zPosition = Layer.Foreground
		water.size = CGSize(width: size.width, height: size.height * 0.2139)
		addChild(water)
  }
  
  fileprivate func setUpPrize() {
		prize = SKSpriteNode(imageNamed: ImageName.Prize)
		prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
		prize.zPosition = Layer.Prize
		prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.Prize), size: prize.size)
		prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
		prize.physicsBody?.collisionBitMask = 0
		prize.physicsBody?.density = 0.5
		
		addChild(prize)
  }
  
  //MARK: - Vine methods
	
	//通过文件的形式来加载葡萄藤的位置，避免重复代码
  fileprivate func setUpVines() {
		// 1 加载葡萄藤数据
		let dataFile = Bundle.main.path(forResource: GameConfiguration.VineDataFile, ofType: nil)
		let vines = NSArray(contentsOfFile: dataFile!) as! [NSDictionary]
		
		// 2 添加葡萄藤
		for i in 0..<vines.count {
			// 3 创建葡萄藤
			let vineData = vines[i]
			let length = Int(vineData["length"] as! NSNumber)
			let relAnchorPoint = CGPointFromString(vineData["relAnchorPoint"] as! String)
			let anchorPoint = CGPoint(x: relAnchorPoint.x * size.width,
																y: relAnchorPoint.y * size.height)
			let vine = VineNode(length: length, anchorPoint: anchorPoint, name: "\(i)")
			
			// 4 添加到创建中
			vine.addToScene(self)
			
			// 5 将葡萄藤的另一端连接到奖励
			vine.attachToPrize(prize)
		}
  }
  
  //MARK: - Croc methods
  
  fileprivate func setUpCrocodile() {
		
		crocodile = SKSpriteNode(imageNamed: ImageName.CrocMouthClosed)
		crocodile.position = CGPoint(x: size.width * 0.75, y: size.height * 0.312)
		crocodile.zPosition = Layer.Crocodile
		crocodile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.CrocMask), size: crocodile.size)
		//categoryBitMask 定义了身体所属的物理类别 —— PhysicsCategory。在这里就是鳄鱼。我们把 collisionBitMask 设置为 0 因为我们不希望鳄鱼把其它身体弹飞。我们需要知道的就是何时”奖励“身体会接触到鳄鱼，所以我们设置了响应的 contactTestBitMask
		crocodile.physicsBody?.categoryBitMask = PhysicsCategory.Crocodile
		crocodile.physicsBody?.collisionBitMask = 0
		crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.Prize
		//不希望鳄鱼的位置有变动，所以关闭了动画
		crocodile.physicsBody?.isDynamic = false
		
		addChild(crocodile)
		
		animateCrocodile()

  }
  
  fileprivate func animateCrocodile() {
		//除了要让小鳄鱼显得很焦虑外，这段代码还创建了一些改变鳄鱼节点的纹理的动作，使其在闭嘴和张嘴之间交替
		let duration = 2.0 + drand48() * 2.0
		let open = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
		let wait = SKAction.wait(forDuration: duration)
		let close = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
		let sequence = SKAction.sequence([wait, open, wait, close])
		
		crocodile.run(SKAction.repeatForever(sequence))
    
  }
  
  fileprivate func runNomNomAnimationWithDelay(_ delay: TimeInterval) {
    
		crocodile.removeAllActions()
		
		let closeMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthClosed))
		let wait = SKAction.wait(forDuration: delay)
		let openMouth = SKAction.setTexture(SKTexture(imageNamed: ImageName.CrocMouthOpen))
		let sequence = SKAction.sequence([closeMouth, wait, openMouth, wait, closeMouth])
		
		crocodile.run(sequence)
  }
  
  //MARK: - Touch handling
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		vineCut = false
	}
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let startPoint = touch.location(in: self)
			let endPoint = touch.previousLocation(in: self)
			
			//检查是否切割葡萄藤
			//对于每次触摸，都会获得它的当前和前一个位置。接下来，使用 SKScene 非常便捷的方法 enumerateBodies(alongRayStart:end:using:)，遍历循环这两点间的场景中所有的身体。对于遇到的每个身体，都会调用 checkIfVineCutWithBody()，我们马上就会写这个方法。
		
			scene?.physicsWorld.enumerateBodies(alongRayStart: startPoint, end: endPoint, using: { (body, point, normal, stop) in
				self.checkIfVineCutWithBody(body)
			})
			
			//产生一些好看的颗粒
			showMoveParticles(touchPosition: startPoint)
		}
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    particles?.removeFromParent()
    particles = nil
  }
  
  fileprivate func showMoveParticles(touchPosition: CGPoint) {
    if particles == nil {
      particles = SKEmitterNode(fileNamed: "Particle.sks")
      particles!.zPosition = 1
      particles!.targetNode = self
      addChild(particles!)
    }
    particles!.position = touchPosition
  }
  
  //MARK: - Game logic
  //SKScene 提供了一个 update() 方法，每帧都会调用一次
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
		
		if levelOver {
			return
		}
		
		if prize.position.y <= 0 {
			run(splashSoundAction)
			splash.impactOccurred()
			switchToNewGameWithTransition(SKTransition.fade(withDuration: 1.0))
			levelOver = true
		}
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
		
		if levelOver {
			return
		}
		
		if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
			|| (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
			
			// 把菠萝缩小出去
			let shrink = SKAction.scale(to: 0, duration: 0.08)
			let removeNode = SKAction.removeFromParent()
			let sequence = SKAction.sequence([shrink, removeNode])
			prize.run(sequence)
			
			runNomNomAnimationWithDelay(0.15)
			run(nomNomSoundAction)
			chomp.impactOccurred()
			// 转到下一关
			switchToNewGameWithTransition(SKTransition.doorway(withDuration: 1.0))
			levelOver = true
		}
		
  }
  
  fileprivate func checkIfVineCutWithBody(_ body: SKPhysicsBody) {
		
		if vineCut && !GameConfiguration.CanCutMultipleVinesAtOnce {
			return
		}
		
		let node = body.node!
		
		// 如果有 name，就必然是葡萄藤节点
		if let name = node.name {
			// 切断葡萄藤
			node.removeFromParent()
			run(sliceSoundAction)
			// 让所有名字匹配的节点淡出
			enumerateChildNodes(withName: name, using: { (node, stop) in
				let fadeAway = SKAction.fadeOut(withDuration: 0.25)
				let removeNode = SKAction.removeFromParent()
				let sequence = SKAction.sequence([fadeAway, removeNode])
				node.run(sequence)
			})
			
			crocodile.removeAllActions()
			crocodile.texture = SKTexture(imageNamed: ImageName.CrocMouthOpen)
			animateCrocodile()
		}
		vineCut = true
  }
  
  fileprivate func switchToNewGameWithTransition(_ transition: SKTransition) {
    
		let delay = SKAction.wait(forDuration: 1)
		let sceneChange = SKAction.run({
			let scene = GameScene(size: self.size)
			//使用了 SKView 的 presentScene(_:transition:) 方法来呈现下一个场景。
			self.view?.presentScene(scene, transition: transition)
		})
		
		run(SKAction.sequence([delay, sceneChange]))
		
		
  }
  
  //MARK: - Audio
  
  fileprivate func setUpAudio() {
		
		//检查 backgroundMusicPlayer 是否已经被创建。如果没有，就用我们之前添加到 Constants.swift 的  BackgroundMusic 常量（被转化为 URL）初始化一个新的 AVAudioPlayer ，然后将其分配给属性。numberOfLoops 被设置为 -1，表示音乐会无限循环。
		
		if GameScene.backgroundMusicPlayer == nil {
			let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
			
			do {
				let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
				GameScene.backgroundMusicPlayer = theme
				
			} catch {
				// 无法加载文件 :[
			}
			
			GameScene.backgroundMusicPlayer.numberOfLoops = -1
		}
		
		if !GameScene.backgroundMusicPlayer.isPlaying {
			GameScene.backgroundMusicPlayer.play()
		}
		
		sliceSoundAction = SKAction.playSoundFileNamed(SoundFile.Slice, waitForCompletion: false)
		splashSoundAction = SKAction.playSoundFileNamed(SoundFile.Splash, waitForCompletion: false)
		nomNomSoundAction = SKAction.playSoundFileNamed(SoundFile.NomNom, waitForCompletion: false)
		
  }
  
}
