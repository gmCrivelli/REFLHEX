//
//  GameOverNode.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 01/02/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverNode: SKNode {

    // MARK: Properties

    // Child nodes
    private var darkenerRectangle: SKShapeNode?
    private var box: SKNode!
    public var restartButton: SKSpriteNode!
    public var menuButton: SKSpriteNode!

    public var scoreLabelTop: SKLabelNode!
    public var scoreLabelBot: SKLabelNode!
    public var comboLabelTop: SKLabelNode!
    public var comboLabelBot: SKLabelNode!
    public var newBestScore: SKLabelNode!
    public var newBestCombo: SKLabelNode!

    // Action for movement
    private var moveBoxAction: SKAction!

    func setup(rectOf size: CGSize) {
        // Setup child nodes
        self.box = self.childNode(withName: "box")

        self.restartButton = box?.childNode(withName: "restartButton") as? SKSpriteNode
        self.menuButton = box?.childNode(withName: "menuButton") as? SKSpriteNode
        self.scoreLabelTop = box?.childNode(withName: "ScoreTop") as? SKLabelNode
        self.scoreLabelBot = box?.childNode(withName: "ScoreBot") as? SKLabelNode
        self.comboLabelTop = box?.childNode(withName: "ComboTop") as? SKLabelNode
        self.comboLabelBot = box?.childNode(withName: "ComboBot") as? SKLabelNode
        self.newBestScore = box?.childNode(withName: "NewBestScore") as? SKLabelNode
        self.newBestCombo = box?.childNode(withName: "NewBestCombo") as? SKLabelNode

        // Darkener for the rest of the screen
        if let darkRect = self.darkenerRectangle {
            darkRect.alpha = 0
        } else {
            self.darkenerRectangle = SKShapeNode(rectOf: size)
            self.darkenerRectangle!.fillColor = .black
            self.darkenerRectangle!.alpha = 0
            self.darkenerRectangle!.zPosition = -1
            self.addChild(darkenerRectangle!)
        }

        self.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.zPosition = 100
        self.box.position = CGPoint(x: 0, y: 4000)

        moveBoxAction = SKAction.move(to: CGPoint.zero, duration: 5)
    }

    // MARK: Show box on screen
    func displayBox(duration: TimeInterval) {

        self.box.position = CGPoint(x: 0, y: 0)
        self.darkenerRectangle!.alpha = 1
    }

    func hideBox() {
        self.box.position = CGPoint(x: 0, y: -4000)
    }

    func setScore(score: Int, newBest: Bool) {
        self.scoreLabelBot.text = String(score)
        self.scoreLabelTop.text = String(score)
        self.newBestScore.isHidden = !newBest
    }

    func setCombo(maxCombo: Int, newBest: Bool) {
        self.comboLabelBot.text = String(maxCombo) + "x"
        self.comboLabelTop.text = String(maxCombo) + "x"
        self.newBestCombo.isHidden = !newBest
    }
}
