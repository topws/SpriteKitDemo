
//  VineNode.swift
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

import UIKit
import SpriteKit

class VineNode: SKNode {
	
	private let length: Int
	private let anchorPoint: CGPoint
	private var vineSegments: [SKNode] = []
	
  init(length: Int, anchorPoint: CGPoint, name: String) {
    self.length = length
		self.anchorPoint = anchorPoint
    super.init()
		
		self.name = name
  }
  
  required init?(coder aDecoder: NSCoder) {
    
		length = aDecoder.decodeInteger(forKey: "length")
		anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")
		
		super.init(coder: aDecoder)
  }
  
  func addToScene(_ scene: SKScene) {
    
		// 把葡萄藤加到场景中
		zPosition = Layer.Vine
		scene.addChild(self)
		
		// 创建葡萄藤架
		let vineHolder = SKSpriteNode(imageNamed: ImageName.VineHolder)
		vineHolder.position = anchorPoint
		vineHolder.zPosition = 1
		
		addChild(vineHolder)
		
		vineHolder.physicsBody = SKPhysicsBody(circleOfRadius: vineHolder.size.width / 2)
		vineHolder.physicsBody?.isDynamic = false
		vineHolder.physicsBody?.categoryBitMask = PhysicsCategory.VineHolder
		vineHolder.physicsBody?.collisionBitMask = 0
		
		// 添加葡萄藤的各个部分
		for i in 0..<length {
			let vineSegment = SKSpriteNode(imageNamed: ImageName.VineTexture)
			let offset = vineSegment.size.height * CGFloat(i + 1)
			vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
			vineSegment.name = name
			
			vineSegments.append(vineSegment)
			addChild(vineSegment)
			
			vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
			vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.Vine
			vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.VineHolder
		}
		
		// 为藤架设置接头
		let joint = SKPhysicsJointPin.joint(withBodyA: vineHolder.physicsBody!,
																				bodyB: vineSegments[0].physicsBody!,
																				anchor: CGPoint(x: vineHolder.frame.midX, y: vineHolder.frame.midY))
		scene.physicsWorld.add(joint)
		
		// 在葡萄藤分段间增加接头
		//这段代码设置了分段间的物理接头，把分段连接在了一起。我们用的接头类型是 SKPhysicsJointPin，它表现的就像用锤子把两个节点钉在一起，这两个节点可以绕着钉子转动，但是不能彼此靠近或远离。
		for i in 1..<length {
			let nodeA = vineSegments[i - 1]
			let nodeB = vineSegments[i]
			let joint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!,
																					anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
			
			scene.physicsWorld.add(joint)
		}
	
}
  
  func attachToPrize(_ prize: SKSpriteNode) {
    
		// 连接奖励和葡萄藤的最后一段
		let lastNode = vineSegments.last!
		lastNode.position = CGPoint(x: prize.position.x, y: prize.position.y + prize.size.height * 0.1)
		
		// 设置连接接头
		let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
																				bodyB: prize.physicsBody!, anchor: lastNode.position)
		
		prize.scene?.physicsWorld.add(joint)
  }
}

