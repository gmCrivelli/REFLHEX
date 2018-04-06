//
//  RestartState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class RestartState: GameState {

    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }

    override func setUpState() {
        //print("RESTART STATE")
        gameScene.prepGame()
        gameScene.gameState = PlayingState(gameScene: gameScene)
    }

    override func processTouches(touches: Set<UITouch>) {
        for t in touches {
            let locationTop = t.location(in: gameScene)
            let nodeArray = gameScene.nodes(at: locationTop)
            if nodeArray.count > 0 {
                if nodeArray[0].name == "pause" {
                    gameScene.gameState = PausedState(gameScene: gameScene!)
                    break
                }
            }
            
            let location = t.location(in: gameScene.hexagonMap)
            let column = gameScene.hexagonMap.tileColumnIndex(fromPosition: location)
            let row = gameScene.hexagonMap.tileRowIndex(fromPosition: location)
            let tile = gameScene.hexagonMap.tileDefinition(atColumn: column, row: row)
            
            if tile?.name != nil {
                if let chosenHexagon = gameScene.hexagonManager.fetchHexagon(column: column, row: row) {
                    chosenHexagon.tap()
                } else {
                    gameScene.takeMissHit()
                }
            }
        }
    }
}
