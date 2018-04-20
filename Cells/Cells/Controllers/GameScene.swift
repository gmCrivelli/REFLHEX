//
//  GameScene.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import AudioToolbox
import SpriteKit
import GameplayKit
import CoreMotion

// Game loop. Should control game states, in-game variables,
// link to a pause menu, a game over screen and Game Center.
// This is also going to be responsible for the main menu.

class GameScene: SKScene {

    /// MARK: Properties

    // Game Center delegate
    public weak var gameCenterDelegate: GameCenterDelegate!

    // Local Stat Saver Service
    var statSaverService: StatSaverProtocol!

    // View Controller delegate
    public weak var viewControllerDelegate: GameViewController!

    // Game State (observable)
    @objc public dynamic var gameState: GameState!

    // Nodes
    var root: SKNode!
    var hexRoot: SKNode!
    var effectNode: SKEffectNode!
    var backgroundNode: SKSpriteNode!
    var foregroundNode: SKSpriteNode!
    var cameraNode: SKCameraNode!
    public var pauseGameNode: PauseGameNode!
    public var gameOverNode: GameOverNode!

    var healthCrop: SKCropNode!
    var healthMask: SKSpriteNode!
    var healthBar: SKSpriteNode!

    public var scoreHUD: SKNode!
    public var mainMenuHUD: SKNode!
    var scoreLabelTop: SKLabelNode!
    var scoreLabelBot: SKLabelNode!
    var comboLabelTop: SKLabelNode!
    var comboLabelBot: SKLabelNode!
    var pauseButton: SKSpriteNode!

    var emmiterHolderNode: SKNode!
    var emmiter: SKEmitterNode?
    let emmiterRadius: Double = 800.0
    var emmiterAngle: Double!
    var emmiterSpinRadsPerSec: Double!

    // Hexagon-related
    public var hexagonMap: SKTileMapNode!
    public var hexagonMapTiles: [SKTileGroup]!
    public var hexagonManager: HexagonManager = HexagonManager()

    // Game control variables
    var maxConcurrentHexagons: Int = 0
    var currentHexagons: Int = 0

    var difficultyBase: Int = 1
    var difficultyLevel: CGFloat! {
        didSet {
            self.difficultyLevel = max(difficultyLevel, 0.5)
        }
    }
    var scoreThresholds: [Int] = [1500, 4500, 8000, 12000, 20000]
    var difficultyScaler: CGFloat!

    var health: CGFloat = 100 {
        didSet {
            self.health = min(health, 100)
        }
    }
    var healthDownPerSec: CGFloat = 8.0
    let healthDownDownPerSec: CGFloat = 0.02

    var score: Int = 0 {
        didSet {
            self.scoreLabelBot.text = String(score)
            self.scoreLabelTop.text = String(score)
        }
    }
    var combo: Int = 1 {
        didSet {
            self.comboLabelBot.text = String(combo) + "x"
            self.comboLabelTop.text = String(combo) + "x"
        }
    }
    var maxCombo: Int = 1

    // Game music
    var musicPlayer: MusicPlayer = MusicPlayer()

    // Actions
    var colorizeActionSequence: SKAction!
    var colorizeActionSequenceSuccess: SKAction!
    var spaceSpawnActionSequence: SKAction!
    var hexSpawnActionSequence: SKAction!
    var thumpSfx: SKAction!
    var popSfx: SKAction!

    // Update control
    var lastUpdate: TimeInterval = 0
    var timeSinceLastUpdate: TimeInterval = -1

    // Miscellaneous
    let feedbackGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    var observer: NSKeyValueObservation?
}
