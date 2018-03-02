//
//  RestartState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class RestartState : GameState {
    
    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }
    
    override func setUpState() {
        print("RESTART STATE")
        gameScene.prepGame()
        gameScene.gameState = PlayingState(gameScene: gameScene)
    }
    
    override func processTouches(touches: Set<UITouch>) {
        for t in touches {
            let locationTop = t.location(in: gameScene)
            if let node = gameScene.nodes(at: locationTop)[0] as? SKNode {
                if node.name == "pause" {
                    gameScene.gameState = PausedState(gameScene: gameScene!)
                    break
                }
            }
            
            let location = t.location(in: gameScene.hexagonMap)
            let column = gameScene.hexagonMap.tileColumnIndex(fromPosition: location)
            let row = gameScene.hexagonMap.tileRowIndex(fromPosition: location)
            let tile = gameScene.hexagonMap.tileDefinition(atColumn: column, row: row)
            if let _ = tile?.name {
                
                if let chosenHexagon = gameScene.hexagonManager.fetchHexagon(column: column, row: row) {
                    chosenHexagon.tap()
                }
                else {
                    gameScene.takeMissHit()
                }
            }
        }
    }
}
