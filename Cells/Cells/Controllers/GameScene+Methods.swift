//
//  GameScene+Methods.swift
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
    /// MARK: Methods
    func prepMenu() {
        
        self.emmiter?.removeFromParent()
        
        setupCamera()
        setupEffects()
        setupMap()
        
        self.root.removeAllActions()
        self.hexRoot.removeAllChildren()
        
        self.scoreHUD.removeAllActions()
        self.scoreHUD.position = CGPoint(x: 0, y: 300)
        self.mainMenuHUD.removeAllActions()
        self.mainMenuHUD.position = CGPoint(x: 0, y: 0)
        
        self.root.isPaused = false
        self.pauseButton!.isHidden = true
        self.pauseGameNode!.isHidden = true
        self.gameOverNode!.isHidden = true
        
        let menuButtons = hexagonManager.getMainMenuHexagons()
        for hex in menuButtons {
            self.hexRoot.addChild(hex)
            hex.position = getScreenPositionOfTile(index: hex.matrixLocation)
            hex.gameSceneDelegate = self
            hex.zPosition = 1
        }
        
        self.mainMenuHUD.alpha = 1
        self.pauseGameNode!.isHidden = true
        
        self.musicPlayer.stopBackgroundMusic()
    }
    
    func prepGame() {
        
        setupCamera()
        setupIngameVariables()
        setupMusic()
        setupMap()
        
        self.hexRoot.removeAllChildren()
        
        self.root.isPaused = false
        self.pauseGameNode!.isHidden = true
        self.gameOverNode!.isHidden = true
        
        self.pauseButton.isHidden = false
        self.healthBar.position = CGPoint(x: 0, y: self.healthBar.position.y)
        
        self.root.run(SKAction.repeatForever(spaceSpawnActionSequence), withKey: "spaceSpawn")
        self.root.run(SKAction.repeatForever(hexSpawnActionSequence), withKey: "hexSpawn")
    }
    
    // This adapts the difficulty as you play!
    func considerChangingDifficulty() {
        guard difficultyBase < scoreThresholds.count else { return }
        
        if self.score > scoreThresholds[difficultyBase] {
            difficultyBase += 1
            if difficultyBase % 2 == 0 {
                maxConcurrentHexagons += 1
                addHexagon()
            }
        }
        
        let difficultyAdapter = (1.0 + difficultyScaler / 100.0)
        self.difficultyLevel = CGFloat(difficultyBase)/2 + difficultyAdapter
    }
    
    // Adds an Hexagon to the game.
    func addHexagon() {
        
        // We only add an Hexagon if we aren't at max capacity.
        guard currentHexagons < maxConcurrentHexagons else { return }
        
        // Get an array of Hexagon instances from the manager
        let randomType = self.hexagonManager.pickHexagonType()
        let newHexs = self.hexagonManager.newHexagon(type: randomType, difficulty: difficultyLevel)
        
        // Adds each Hexagon to the scene (most likely there will only be one)
        for hex in newHexs {
            hex.gameSceneDelegate = self
            hex.position = getScreenPositionOfTile(index: hex.matrixLocation)
            hex.xScale = 0.0
            hex.yScale = 0.0
            hex.zPosition = 1
            hex.run(SKAction.scale(to: 1.0, duration: 0.13))
            hexRoot.addChild(hex)
        }
        
        // Increments current Hexagon count.
        self.currentHexagons += 1
    }
    
    // Returns the corresponding screen coordinates of a given M_Index.
    func getScreenPositionOfTile(index: (Int, Int)) -> CGPoint {
        
        let width = self.hexagonMap.tileSize.width
        let center = CGPoint(x: self.cameraNode.position.x, y: self.hexagonMap.position.y)
        let (i, j) = index - self.hexagonManager.centerOffset
        let middle = CGFloat(i) - CGFloat(abs(j % 2))/2
        let xPosition = center.x + middle * width
        let yPosition = center.y + CGFloat(j) * width * sqrt(3)/2
        
        return  CGPoint(x: xPosition, y: yPosition)
    }
    
    // Removes a given Hexagon.
    func removeHexagon(_ hexagon: Hexagon) {
        hexagon.removeAllChildren()
        hexagon.removeAllActions()
        hexagon.removeFromParent()
        hexagonManager.removeHexagon(at: hexagon.matrixLocation)
    }
    
    // Hexagon Success! Add the Hexagon value to the score, increment combo,
    // spawn a new Hexagon and remove the old one from the game.
    func hexSuccess(hexagon: Hexagon) {
        
        if hexagon.type == HexagonType.neighborSlave {
            if let hex = hexagon as? NeighborSlaveHexagon {
                hex.masterHexagon.notify()
                removeHexagon(hexagon)
                NeighborSlaveHexagon.staticAlpha -= 0.15
            }
            return
        }
        
        self.hexagonManager.progressUnlock(type: hexagon.type)
        
        playGoodHitEffects(hexagon: hexagon)
        
        let floatPoints = CGFloat(hexagon.points)
        let multiplier = CGFloat(self.combo - 1) / 10.0 + max(0.0, log10(difficultyLevel))
        self.score += 10 * Int(floatPoints * (1.0 + multiplier))
        self.health += hexagon.restoration
        self.combo += 1
        if combo > maxCombo {
            maxCombo = combo
        }
        self.currentHexagons -= 1
        
        self.difficultyScaler = difficultyScaler + 1
        self.considerChangingDifficulty()
        
        if score > 1000 {
            let dbScore = Double(score)
            self.emmiter?.particleSpeed = CGFloat(500 + 250 * (log10(dbScore) - 3))
        }
        self.addHexagon()
        removeHexagon(hexagon)
        
    }
    
    // Hexagon Failure... Reset the combo, suffer a health penalty, play effects,
    // spawn a new Hexagon and remove the old one from the game.
    func hexFailure(hexagon: Hexagon) {
        
        if hexagon.type == HexagonType.neighborMaster {
            if let hex = hexagon as? NeighborMasterHexagon {
                removeHexagon(hex.slaveHexagon)
            }
        }
        
        self.playBadHitEffects(hexagon: hexagon)
        self.health -= hexagon.penalty
        self.combo = 1
        self.currentHexagons -= 1
        
        self.difficultyScaler = difficultyScaler - 3
        considerChangingDifficulty()
        
        self.addHexagon()
        removeHexagon(hexagon)
    }
    
    func takeMissHit() {
        self.health -= 5
        self.combo = 1
        self.difficultyScaler = difficultyScaler - 3
        playBadHitEffects(hexagon: nil)
    }
    
    // Sound and screen effects for Hexagon success.
    func playGoodHitEffects(hexagon: Hexagon?) {
        
        // Colors the background in lovely tones of Victory Green
        self.removeAction(forKey: "bgHit")
        self.backgroundNode.run(colorizeActionSequenceSuccess, withKey: "bgHit")
        
        // ~pop~
        self.run(popSfx, withKey: "pop")
        
        // Vibrate
        AudioServicesPlaySystemSound(1519) // Actuate `pip` feedback (weak boom)
    }
    
    // Sound and screen effects for Hexagon failure.
    func playBadHitEffects(hexagon: Hexagon?) {
        
        // Shakes the camera
        shakeCamera(duration: 0.25)
        
        // Colors the background in a beautiful shade of Loser Red
        self.removeAction(forKey: "bgHit")
        self.backgroundNode.run(colorizeActionSequence, withKey: "bgHit")
        
        // Lowers the music volume for a small amount of time
        self.removeAction(forKey: "musicAction")
        let duration: CGFloat = 0.7
        let musicAction = SKAction.customAction(withDuration: Double(duration),
                                                actionBlock: { [weak self] _, elapsedTime in
                                        let normalizedTime = elapsedTime / duration
                                        self?.musicPlayer.setVolume(volume: Float(normalizedTime * normalizedTime))
        })
        self.run(musicAction, withKey: "musicAction")
        
        // THUMP.
        self.run(thumpSfx, withKey: "sfxAction")
        
        // Vibrate
        AudioServicesPlaySystemSound(1521) // Actuate `Pop` feedback (strong boom)
        
    }
    
    // Auxiliary function for shaking the camera lightly upon errors
    func shakeCamera(duration: Float) {
        
        cameraNode.removeAction(forKey: "shake")
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let amplitudeX: CGFloat = 12
        let amplitudeY: CGFloat = 12
        let numberOfShakes = duration / 0.04
        var actionsArray: [SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2
            let moveY = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2
            let shakeAction = SKAction.moveBy(x: moveX, y: moveY, duration: 0.02)
            shakeAction.timingMode = SKActionTimingMode.easeOut
            actionsArray.append(shakeAction)
            actionsArray.append(shakeAction.reversed())
        }
        
        let actionSeq = SKAction.sequence(actionsArray)
        cameraNode.run(actionSeq, withKey: "shake")
    }
    
    //Pause the game and display the pause menu
    func pauseGame() {
        self.pauseGameNode!.isHidden = false
        self.pauseGameNode!.displayBox(duration: 0.1)
        self.root.isPaused = true
        self.musicPlayer.setVolume(volume: 0.2)
    }
    
    //Pause the game and display the pause menu
    func unpauseGame() {
        self.pauseGameNode!.isHidden = true
        self.root.isPaused = false
        self.musicPlayer.setVolume(volume: 1.0)
    }
    
    func gameOver() {
        self.root.removeAllActions()
        self.hexRoot.removeAllChildren()
        
        let isBestScore = statSaverService.updateBestScore(score: score)
        let isBestCombo = statSaverService.updateBestCombo(combo: maxCombo)
        
        if isBestScore {
            gameCenterDelegate.submit(score: score)
        }
        if isBestCombo {
            gameCenterDelegate.submit(maxCombo: maxCombo)
        }
        
        self.gameOverNode.setScore(score: score, newBest: isBestScore)
        self.gameOverNode.setCombo(maxCombo: maxCombo, newBest: isBestCombo)
        
        gameOverAnimation(duration: 2.0)
    }
    
    func gameOverAnimation(duration: TimeInterval) {
        
        var actionSequence: [SKAction] = [SKAction]()
        var openHexagons = hexagonManager.getAllOpenHexagons()
        let timePerHex = duration / Double(openHexagons.count)
        let waitAction = SKAction.wait(forDuration: timePerHex)
        
        while openHexagons.count > 0 {
            let index = openHexagons.removeLast()
            let deleteAction = SKAction.run {
                [weak self] in
                self?.hexagonMap.setTileGroup(nil, forColumn: index.0, row: index.1)
                AudioServicesPlaySystemSound(1521) // Actuate `Pop` feedback (strong boom)
            }
            actionSequence.append(deleteAction)
            actionSequence.append(thumpSfx)
            actionSequence.append(waitAction)
        }
        
        shakeCamera(duration: Float(duration))
        self.run(SKAction.sequence(actionSequence), completion: {
            [weak self] in
            self?.run((self?.thumpSfx)!)
            self?.gameOverNode!.isHidden = false
            self?.gameOverNode!.displayBox(duration: 0.1)
            //self.musicPlayer.setVolume(volume: 0.2)
        })
    }
    
    func displayGCLeaderboards() {
        self.gameCenterDelegate.checkGCLeaderboard()
    }
    
    // Detect touches and deal with them
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameState.processTouches(touches: touches)
    }
    
    // Updates the game elements
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        guard lastUpdate != 0 else {
            lastUpdate = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdate
        lastUpdate = currentTime
        
        if self.gameState.isKind(of: PlayingState.self) {
            
            hexagonManager.update(timeElapsed: deltaTime)
            
            self.healthDownPerSec += healthDownDownPerSec * CGFloat(deltaTime)
            self.health -= healthDownPerSec * difficultyLevel * CGFloat(deltaTime)
            let healthPercent = 1 - self.health / 100.0
            self.healthBar.position = CGPoint(x: -healthBar.size.width * healthPercent, y: healthBar.position.y)
            self.healthBar.colorBlendFactor = 4 * healthPercent - 1.5
            
            if self.health <= 0 {
                self.gameState = GameOverState(gameScene: self)
            }
            
            // Camera slowly zooms out
            self.cameraNode.xScale = min(cameraNode.xScale + 0.00007, 0.65)
            self.cameraNode.yScale = min(cameraNode.yScale + 0.00007, 0.65)
            
            // Emmiter node slowly spins around the game
            emmiterHolderNode.zRotation += CGFloat(deltaTime * emmiterSpinRadsPerSec)
        }
    }
    
    func displayAbout() {
        self.viewControllerDelegate.displayAbout()
    }
}
