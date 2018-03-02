//
//  GameOverState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverState : GameState {
    
    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }
    
    override func setUpState() {
        print("GAME OVER STATE")
        gameScene.gameOver()
    }
    
    override func processTouches(touches: Set<UITouch>) {
        if gameScene.gameOverNode!.menuButton.contains((touches.first?.location(in: gameScene.pauseGameNode!))!) {
            gameScene.gameState = MenuState(gameScene: gameScene!)
        }
        else if gameScene.gameOverNode!.restartButton.contains((touches.first?.location(in: gameScene.pauseGameNode!))!) {
            gameScene.gameState = RestartState(gameScene: gameScene!)
        }
        
    }
}
