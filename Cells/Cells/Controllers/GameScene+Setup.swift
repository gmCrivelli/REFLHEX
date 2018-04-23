//
//  GameScene+Setup.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 06/04/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import AudioToolbox
import SpriteKit
import GameplayKit
import CoreMotion

extension GameScene {
    /// MARK: Setups
    override func didMove(to view: SKView) {
        initialSetup()
    }
    
    // Should only be called on didMove. This makes testing easier.
    func initialSetup() {
        self.statSaverService = StatSaverService()
        setupNodes()
        setupActions()
        
        //Set up Observer for gameState changes
        observer = self.observe(\.gameState, options: [.new]) { (_, currentGameState) in
            if let currentGameState = currentGameState.newValue {
                currentGameState.setUpState()
            }
        }
        
        self.gameState = MenuState(gameScene: self)
        feedbackGenerator.prepare()
    }
    
    func setupNodes() {
        
        self.root = self.childNode(withName: "root")
        self.hexRoot = SKNode()
        self.root.addChild(hexRoot)
        
        self.cameraNode = root.childNode(withName: "gameCamera") as? SKCameraNode
        self.camera = cameraNode
        
        self.backgroundNode = root.childNode(withName: "backgroundNode") as? SKSpriteNode
        
        self.scoreHUD = self.cameraNode.childNode(withName: "scoreHUD")
        self.scoreLabelTop = self.scoreHUD.childNode(withName: "scoreLabelTop") as? SKLabelNode
        self.scoreLabelBot = self.scoreHUD.childNode(withName: "scoreLabelBot") as? SKLabelNode
        self.comboLabelTop = self.scoreHUD.childNode(withName: "comboLabelTop") as? SKLabelNode
        self.comboLabelBot = self.scoreHUD.childNode(withName: "comboLabelBot") as? SKLabelNode
        
        self.mainMenuHUD = self.cameraNode.childNode(withName: "mainMenuHUD")
        
        self.healthCrop = SKCropNode()
        self.healthMask = SKSpriteNode(imageNamed: "Filled")
        self.healthCrop.maskNode = healthMask
        self.healthBar = self.cameraNode.childNode(withName: "healthBar") as? SKSpriteNode
        self.healthBar.removeFromParent()
        self.healthCrop.addChild(healthBar)
        self.healthCrop.xScale = 0.27
        self.healthCrop.yScale = 0.27
        self.healthCrop.position = CGPoint(x: 0, y: scoreLabelTop.position.y + 67)
        self.scoreHUD.addChild(healthCrop)
        
        self.healthBar.xScale = 1.0
        
        self.hexagonMap = root.childNode(withName: "hexagonMap") as? SKTileMapNode
        
        let pauseGameScene = SKScene(fileNamed: "PausedGameScene")
        self.pauseGameNode = pauseGameScene?.childNode(withName: "root") as? PauseGameNode
        self.pauseGameNode!.removeFromParent()
        self.addChild(self.pauseGameNode!)
        self.pauseGameNode!.setup(rectOf: self.size)
        self.pauseButton = self.cameraNode.childNode(withName: "pause") as? SKSpriteNode
        
        let gameOverScene = SKScene(fileNamed: "GameOverScene")
        self.gameOverNode = gameOverScene?.childNode(withName: "root") as? GameOverNode
        self.gameOverNode!.removeFromParent()
        self.addChild(self.gameOverNode!)
        self.gameOverNode!.setup(rectOf: self.size)
    }
    
    func setupIngameVariables() {
        self.hexagonManager = HexagonManager()
        
        self.maxConcurrentHexagons = 1
        self.currentHexagons = 0
        self.difficultyScaler = 0
        self.difficultyBase = 0
        self.healthDownPerSec = 8.0
        
        self.score = 0
        self.combo = 1
        self.maxCombo = 1
        self.health = 100
        self.timeSinceLastUpdate = -1
        
        considerChangingDifficulty()
    }
    
    func setupCamera() {
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cameraNode.xScale = 0.4
        cameraNode.yScale = 0.4
    }
    
    func setupActions() {
        
        // Action to change background color upon damage taken
        self.colorizeActionSequence = SKAction.sequence([
            SKAction.colorize(with: #colorLiteral(red: 0.3922310179, green: 0.05500275954, blue: 0.1561482454, alpha: 1), colorBlendFactor: 1.0, duration: 0.0),
            SKAction.colorize(with: #colorLiteral(red: 0, green: 0, blue: 0.1944693408, alpha: 1), colorBlendFactor: 1.0, duration: 0.9)])
        
        self.colorizeActionSequenceSuccess = SKAction.sequence([
            SKAction.colorize(with: #colorLiteral(red: 0.09025930604, green: 0.2447364058, blue: 0.02185824665, alpha: 1), colorBlendFactor: 1.0, duration: 0.0),
            SKAction.colorize(with: #colorLiteral(red: 0, green: 0, blue: 0.1964104095, alpha: 1), colorBlendFactor: 1.0, duration: 2.0)])
        
        // SFX played when success
        self.popSfx = SKAction.playSoundFileNamed("Pop.wav", waitForCompletion: false)
        
        // SFX played when damage taken
        self.thumpSfx = SKAction.playSoundFileNamed("Thump.wav", waitForCompletion: false)
        
        // Action to control automatic spawning of new spaces and new hexagons
        let spawnSpaceAction = SKAction.run {
            [weak self] in
            if let gameScene = self?.scene as? GameScene,
                let hexIndex = gameScene.hexagonManager.getNewHexagonSpace() {
                gameScene.hexagonMap.setTileGroup(self?.hexagonMapTiles[0], forColumn: hexIndex.0, row: hexIndex.1)
            }
        }
        
        let spaceWaitAction = SKAction.wait(forDuration: 10.0)
        let spawnHexagonAction = SKAction.run {
            [weak self] in
            if let gameScene = self?.scene as? GameScene {
                gameScene.addHexagon()
            }
        }
        let spawnWaitAction = SKAction.wait(forDuration: 2.0)
        
        // Save those actions as sequences to be used later
        self.hexSpawnActionSequence = SKAction.sequence([spawnHexagonAction, spawnWaitAction])
        self.spaceSpawnActionSequence = SKAction.sequence([spaceWaitAction, spawnSpaceAction])
    }
    
    func setupMusic() {
        self.musicPlayer = MusicPlayer()
        self.musicPlayer.playBackgroundMusic()
    }
    
    func setupEffects() {
        
        let emmit = SKEmitterNode(fileNamed: "bgParticles")!
        self.emmiterHolderNode = SKNode()
        self.emmiterHolderNode.addChild(emmit)
        self.cameraNode.addChild(emmiterHolderNode)
        self.emmiter = emmit
        self.emmiter?.position = CGPoint(x: -emmiterRadius, y: 0)
        self.emmiter?.zPosition = -20
        self.emmiterAngle = 0.0
        self.emmiterSpinRadsPerSec = 0.01
    }
    
    func setupMap() {
        
        self.hexagonMapTiles = [hexagonMap.tileSet.tileGroups.first(where: {$0.name! == "Disabled"})!]
        
        for xIndex in 0 ... self.hexagonMap.numberOfColumns {
            for yIndex in 0 ... self.hexagonMap.numberOfRows {
                self.hexagonMap.setTileGroup(nil, forColumn: xIndex, row: yIndex)
            }
        }
        
        for (xIndex, yIndex) in hexagonManager.getAllCenterHexagons() {
            self.hexagonMap.setTileGroup(self.hexagonMapTiles[0], forColumn: xIndex, row: yIndex)
        }
    }
}
