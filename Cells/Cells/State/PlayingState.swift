//
//  PlayingState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class PlayingState: GameState {

    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }

    override func setUpState() {
        //print("PLAYING STATE")
        gameScene.unpauseGame()
    }

    override func processTouches(touches: Set<UITouch>) {
        for touch in touches {
            let locationTop = touch.location(in: gameScene)
            let nodes = gameScene.nodes(at: locationTop)
            if nodes.count > 0 {
                let node = nodes[0]
                if node.name == "pause" {
                    gameScene.gameState = PausedState(gameScene: gameScene!)
                    break
                }

                let location = touch.location(in: gameScene.hexagonMap)
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
}
