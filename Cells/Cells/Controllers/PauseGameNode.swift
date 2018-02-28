//
//  PauseMenu.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 31/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class PauseGameNode : SKNode {
    
    // MARK: Properties
    
    // Child nodes
    private var darkenerRectangle : SKShapeNode?
    private var box : SKNode!
    public var restartButton : SKSpriteNode!
    public var continueButton : SKSpriteNode!
    public var menuButton : SKSpriteNode!
    
    // Action for movement
    private var moveBoxAction : SKAction!
    
    func setup(rectOf size: CGSize) {
        // Setup child nodes
        self.box = self.childNode(withName: "box")
        
        self.restartButton = box?.childNode(withName: "restartButton") as! SKSpriteNode
        self.continueButton = box?.childNode(withName: "continueButton") as! SKSpriteNode
        self.menuButton = box?.childNode(withName: "menuButton") as! SKSpriteNode
        
        // Darkener for the rest of the screen
        if let darkRect = self.darkenerRectangle {
            darkRect.alpha = 0
        }
        else {
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
        self.darkenerRectangle!.alpha = 0.85
    }
    
    func hideBox() {
        self.box.position = CGPoint(x: 0, y: -4000)
    }
}

