//
//  Hexagon.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 10/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: Enums

// Enum to list possible Hexagon states.
enum HexagonState : Int {
    case inactive = 0
    case standby = 1
    case pressed = 2
}

// Abstract class for the Hexagons. Should not be instantiated.
class Hexagon : SKSpriteNode {

    // MARK : Properties
    
    // State and type of the Hexagon
    public var state : HexagonState!
    public var type : HexagonType!
    
    // Hexagon life time and time left until it vanishes
    public var lifeTime : TimeInterval!
    public var timeLeft : TimeInterval!
    
    // Score-related properties
    public var points : Int = 1
    public var restoration : CGFloat = 8
    public var penalty : CGFloat = 7
    
    // M_Index of the Hexagon
    public var matrixLocation : (Int, Int)!
    
    // Delegate of the Game Scene for success/failure execution
    public var gameSceneDelegate : GameScene!

    
    /// MARK: Init
    // Receives the name of the image to be loaded as sprite
    init(imageNamed name: String, difficulty: CGFloat) {
        
        // Default life time: 2 seconds
        // Gets lower according to difficulty
        self.lifeTime = Double(max(0.8, 3.0 - 0.5 * difficulty))
        self.timeLeft = self.lifeTime
        
        self.restoration = max(5, 8 * difficulty)
        
        // Initializes the texture. Magic numbers are provisory.
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.xScale = 90.933 / 95
        self.yScale = 105.0 / 109.0
        
        // Initializes the default state and shader.
        self.state = .standby
        self.shader = ShaderManager.sharedInstance.getHexagonShader()
        self.shader?.attributes = [SKAttribute(name: "a_timep", type: .float)]
        self.shader?.uniforms = [ShaderManager.sharedInstance.getHexagonUniform()]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Does nothing right now, but classes that extend Hexagon will use this to communicate.
    public func tap() {
    }
    
    // Updates the time left and eventually triggers a failure,
    // Also updates the shader values.
    public func update(timeElapsed : TimeInterval) {
        
        self.timeLeft = timeLeft - timeElapsed
        
        let percentage = 1 - Float(timeLeft/lifeTime)
        
        self.setValue(SKAttributeValue(float: percentage), forAttribute: "a_timep")
        if timeLeft <= 0 {
            self.gameSceneDelegate.hexFailure(hexagon: self)
        }
    }
}
