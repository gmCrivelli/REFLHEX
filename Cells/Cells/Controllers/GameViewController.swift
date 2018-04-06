//
//  GameViewController.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 02/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

protocol GameCenterDelegate: class {
    func submit(score: Int)
    func submit(maxCombo: Int)
    func checkGCLeaderboard()
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    /// MARK: Properties
    var gameScene: GameScene!
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID

    let SCORELEADERBOARDID = "com.score.reflhex"
    let COMBOLEADERBOARDID = "com.combo.reflhex"
    let COMBINEDLEADERBOARDID = "com.combined.reflhex"

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseGame(_:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)

        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                scene.gameCenterDelegate = self
                scene.viewControllerDelegate = self

                self.gameScene = scene

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = false
            view.showsNodeCount = false
        }

        authenticateLocalPlayer()
    }

    @objc func pauseGame(_ sender: Any?) {
        if gameScene.gameState.isKind(of: PlayingState.self) {
            self.gameScene.gameState = PausedState(gameScene: self.gameScene)
        }
    }

    // MARK: - AUTHENTICATE LOCAL PLAYER FOR GAMECENTER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()

        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if viewController != nil {
                // 1. Show login if player is not logged in
                self.present(viewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true

                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(String(describing: error))
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer!
                    }
                })
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(String(describing: error))
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func displayAbout() {

        let randomAdjectives = ["A", "A quick", "A small", "A challenging",
                                "A lovely", "A frustrating", "An easy",
                                "A hexagonal", "An original", "An everyday",
                                "A revolutionary", "Actually a duck disguised as a",
                                "A crunchy", "A hardcore"]

        let rand = arc4random_uniform(UInt32(randomAdjectives.count))

        var message = "\n\(randomAdjectives[Int(rand)]) game made by Gustavo Crivelli.\n"
        message += "\nMusic: \"Disco High\", by UltraCat.\n"
        message += "\nThanks for playing!"

        let alertController = UIAlertController(title: "About REFLHEX",
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss!", style: UIAlertActionStyle.default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
}

extension GameViewController: GameCenterDelegate {
    func submit(score: Int) {
        // Submit score to GC leaderboard
        guard gcEnabled else { return }

        let bestScoreInt = GKScore(leaderboardIdentifier: SCORELEADERBOARDID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }

    func submit(maxCombo: Int) {
        // Submit score to GC leaderboard
        guard gcEnabled else { return }

        let bestComboInt = GKScore(leaderboardIdentifier: COMBOLEADERBOARDID)
        bestComboInt.value = Int64(maxCombo)
        GKScore.report([bestComboInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Combo submitted to your Leaderboard!")
            }
        }
    }

    func checkGCLeaderboard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .default
        //gcVC.leaderboardIdentifier = SCORELEADERBOARDID
        present(gcVC, animated: true, completion: nil)
    }
}
