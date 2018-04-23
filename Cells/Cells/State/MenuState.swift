//
//  MenuState.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

class MenuState: GameState {

    required init(gameScene: GameScene) {
        super.init(gameScene: gameScene)
    }

    override func setUpState() {
        //print("MENU STATE")
        gameScene.prepMenu()
    }

    override func processTouches(touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: gameScene)
            if let hex = gameScene.nodes(at: location)[0] as? Hexagon {
                hex.tap()
            }
        }
    }
}
