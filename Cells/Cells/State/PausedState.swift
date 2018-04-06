//
//  PausedState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class PausedState: GameState {

    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }

    override func setUpState() {
        //print("PAUSE STATE")
        gameScene.pauseGame()
    }

    override func processTouches(touches: Set<UITouch>) {

        let node = gameScene.pauseGameNode!

        if node.menuButton.contains((touches.first?.location(in: gameScene.pauseGameNode!))!) {
            gameScene.gameState = MenuState(gameScene: gameScene!)
        } else if node.restartButton.contains((touches.first?.location(in: gameScene.pauseGameNode!))!) {
            gameScene.gameState = RestartState(gameScene: gameScene!)
        } else if node.continueButton.contains((touches.first?.location(in: gameScene.pauseGameNode!))!) {
            gameScene.gameState = PlayingState(gameScene: gameScene!)
        }
    }
}
