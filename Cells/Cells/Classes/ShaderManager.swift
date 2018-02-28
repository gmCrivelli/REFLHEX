//
//  ShaderManager.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 26/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

// Singleton class for guaranteeing that only one instace of each shader will be created.

class ShaderManager {
    
    /// MARK: Properties
    
    // Singleton instance
    static let sharedInstance = ShaderManager()
    
    // Hexagon shader-related properties
    private var hexagonShader : SKShader!
    private var hexagonUniform : SKUniform!
    
    // Shader for the game screen (WIP)
    private var waveShader : SKShader!
    private var screenShader : SKShader!
    
    // Private Singleton init
    private init() {
        self.hexagonShader = SKShader(fileNamed: "HexagonTimer.fsh")
        self.hexagonUniform = SKUniform(name: "u_gradient", texture: SKTexture(imageNamed: "hexshader"))
        
        //self.screenShader = SKShader(fileNamed: "ScreenEffect.fsh")
        self.waveShader =  SKShader(fileNamed: "WaveShader.fsh")
    }
    
    /// MARK: Getters for the shaders
    
    func getHexagonShader() -> SKShader {
        return hexagonShader
    }
    
    func getHexagonUniform() -> SKUniform {
        return hexagonUniform
    }
    
    func getWaveShader() -> SKShader {
        return waveShader
    }
//    func getScreenShader() -> SKShader {
//        return screenShader
//    }
}
