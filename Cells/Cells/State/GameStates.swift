//
//  GameStates.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 28/02/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

enum GameStateType {
    case menu
    case playing
    case paused
    case gameOver
    case restart
}

// Abstract state class, should only be used for inheritance, no direct instantiation.
class GameState: NSObject {

    // Should keep a reference to the game scene
    weak var gameScene: GameScene!

    required init(gameScene: GameScene) {
        super.init()
        self.gameScene = gameScene
    }

    /// Setup this state. This will be called by an external observer
    /// whenever the state changes.
    func setUpState() {
        fatalError("Must Overwrite!")
    }

    /// Called whenever there is a tap. Decides how to process it.
    func processTouches(touches: Set<UITouch>) {
        fatalError("Must Overwrite!")
    }
}
