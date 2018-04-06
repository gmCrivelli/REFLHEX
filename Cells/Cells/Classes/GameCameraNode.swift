//
//  GameCameraNode.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 06/04/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class GameCameraNode: SKNode {
    
    public var cameraNode: SKCameraNode!
    
    private var healthCrop: SKCropNode!
    private var healthMask: SKSpriteNode!
    private var healthBar: SKSpriteNode!
    
    public var scoreHUD: SKNode!
    public var mainMenuHUD: SKNode!
    private var scoreLabelTop: SKLabelNode!
    private var scoreLabelBot: SKLabelNode!
    private var comboLabelTop: SKLabelNode!
    private var comboLabelBot: SKLabelNode!
    private var pauseButton: SKSpriteNode!
    
    private var emmiterHolderNode: SKNode!
    private var emmiter: SKEmitterNode?
    private let emmiterRadius: Double = 800.0
    private var emmiterAngle: Double!
    private var emmiterSpinRadsPerSec: Double!
    
    func setup() {
        setupNodes()
        setupCamera()
        setupEffects()
    }
    
    func setupNodes() {
        self.cameraNode = self.childNode(withName: "gameCamera") as? SKCameraNode
        
        self.scoreHUD = self.cameraNode.childNode(withName: "scoreHUD")
        self.scoreLabelTop = self.scoreHUD.childNode(withName: "scoreLabelTop") as? SKLabelNode
        self.scoreLabelBot = self.scoreHUD.childNode(withName: "scoreLabelBot") as? SKLabelNode
        self.comboLabelTop = self.scoreHUD.childNode(withName: "comboLabelTop") as? SKLabelNode
        self.comboLabelBot = self.scoreHUD.childNode(withName: "comboLabelBot") as? SKLabelNode
        
        self.mainMenuHUD = self.cameraNode.childNode(withName: "mainMenuHUD")
        
        self.healthCrop = SKCropNode()
        self.healthMask = SKSpriteNode(imageNamed: "Filled")
        self.healthCrop.maskNode = healthMask
        self.healthBar = self.cameraNode.childNode(withName: "healthBar") as? SKSpriteNode
        self.healthBar.removeFromParent()
        self.healthCrop.addChild(healthBar)
        self.healthCrop.xScale = 0.27
        self.healthCrop.yScale = 0.27
        self.healthCrop.position = CGPoint(x: 0, y: scoreLabelTop.position.y + 67)
        self.scoreHUD.addChild(healthCrop)
        
        self.healthBar.xScale = 1.0
        
        self.pauseButton = self.cameraNode.childNode(withName: "pause") as? SKSpriteNode
    }
    
    func setupEffects() {
        let em = SKEmitterNode(fileNamed: "bgParticles")!
        self.emmiterHolderNode = SKNode()
        self.emmiterHolderNode.addChild(em)
        self.cameraNode.addChild(emmiterHolderNode)
        self.emmiter = em
        self.emmiter?.position = CGPoint(x: -emmiterRadius, y: 0)
        self.emmiter?.zPosition = -20
        self.emmiterAngle = 0.0
        self.emmiterSpinRadsPerSec = 0.01
    }
    
    func setupCamera() {
        self.cameraNode.xScale = 0.4
        self.cameraNode.yScale = 0.4
    }
    
    func prepMenu() {
        self.emmiter?.removeFromParent()
        self.scoreHUD.removeAllActions()
        self.scoreHUD.position = CGPoint(x: 0, y: 300)
        self.mainMenuHUD.removeAllActions()
        self.mainMenuHUD.position = CGPoint(x: 0, y: 0)
        self.mainMenuHUD.alpha = 1
        self.pauseButton!.isHidden = true
    }
    
    func prepGame() {
        self.pauseButton.isHidden = false
        self.healthBar.position = CGPoint(x: 0, y: self.healthBar.position.y)
    }
    
    func updateParticles(to speed: CGFloat) {
        self.emmiter?.particleSpeed = speed
    }
    
    func animateMenu() {
        self.mainMenuHUD.run(SKEase.move(easeFunction: .curveTypeElastic,
                                         easeType: .easeTypeOut,
                                         time: 0.9,
                                         from: CGPoint.zero,
                                         to: CGPoint(x: 0, y: 300)))

        self.scoreHUD.run(SKEase.move(easeFunction: .curveTypeElastic,
                                      easeType: .easeTypeOut,
                                      time: 0.9,
                                      from: self.scoreHUD.position,
                                      to: CGPoint.zero))
    }
    
    func shake(duration: Float) {
        self.cameraNode.removeAction(forKey: "shake")
        self.cameraNode.position = CGPoint.zero
        
        let amplitudeX: CGFloat = 12
        let amplitudeY: CGFloat = 12
        let numberOfShakes = duration / 0.04
        var actionsArray: [SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        
        let actionSeq = SKAction.sequence(actionsArray)
        self.cameraNode.run(actionSeq, withKey: "shake")
    }
    
    func displayScore(_ score: Int) {
        self.scoreLabelBot.text = String(score)
        self.scoreLabelTop.text = String(score)
    }

    func displayCombo(_ combo: Int) {
        self.comboLabelBot.text = String(combo) + "x"
        self.comboLabelTop.text = String(combo) + "x"
    }
    
    func update(deltaTime: TimeInterval, healthPercent: CGFloat) {
        self.healthBar.position = CGPoint(x: -healthBar.size.width * healthPercent, y: healthBar.position.y)
        self.healthBar.colorBlendFactor = 4 * healthPercent - 1.5
        
        // Camera slowly zooms out
        self.cameraNode.xScale = min(cameraNode.xScale + 0.00007, 0.65)
        self.cameraNode.yScale = min(cameraNode.yScale + 0.00007, 0.65)
        
        // Emmiter node slowly spins around the game
        emmiterHolderNode.zRotation += CGFloat(deltaTime * emmiterSpinRadsPerSec)
    }
}
