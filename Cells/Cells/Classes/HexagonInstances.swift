//
//  HexagonInstances.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 26/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

// Every class here is an extension of Hexagon.
// The first few are Menu elements.
// The rest are gameplay elements.

/// MARK: Enums

// These are the possible Hexagon types.
enum HexagonType: Int {
    case disabled = -1
    case singleTap = 0
    case dontTap = 1
    case special = 2
    case multiTap = 3
    case neighborMaster = 4
    case neighborSlave = 5
    case tapHold = 10 // not yet implemented
    case play = 20
    case settings = 21
    case ranking = 22
    case about = 23

    static func pick(_ index: Int) -> HexagonType {
        let array: [HexagonType] = [.singleTap, .dontTap, .special, .multiTap, .neighborMaster]
        return array[index]
    }

    // returns a random Hexagon type according to the below probability distribution
    static func random() -> HexagonType {
        let array: [HexagonType] = [.singleTap, .dontTap, .special, .multiTap, .neighborMaster, .tapHold]
        let probDistribution = [20, 25, 30, 35, 40, 50]

        let randomVal = arc4random_uniform(41)
        var index = 0
        while probDistribution[index] < randomVal {
            index += 1
        }
        return array[index]
    }

    func imageName() -> String {
        switch self {
        case .disabled: return "Disabled"
        case .dontTap: return "Dont Tap Red 2"
        case .special: return "Special"
        case .multiTap: return "Multi Tap"
        case .neighborMaster: return "One Tap"
        case .neighborSlave: return "Slave"
        case .play: return "Play"
        //case .settings: return "Settings"
        case .about: return "About"
        case .ranking: return "Ranking"
        default: return "One Tap"
        }
    }
}

/// MARK: Menu

class PlayHexagon: Hexagon {

    init() {
        super.init(imageNamed: HexagonType.play.imageName(), difficulty: 0)
        self.type = .play
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.animateMenu()
            self.gameSceneDelegate.gameState = RestartState(gameScene: gameSceneDelegate)
        }
    }
}

class SettingsHexagon: Hexagon {

    init() {
        super.init(imageNamed: HexagonType.settings.imageName(), difficulty: 0)
        self.type = .settings
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            print("SETTINGS")
        }
    }
}

class RankingHexagon: Hexagon {

    init() {
        super.init(imageNamed: HexagonType.ranking.imageName(), difficulty: 0)
        self.type = .ranking
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            gameSceneDelegate.displayGCLeaderboards()
        }
    }
}

class AboutHexagon: Hexagon {

    init() {
        super.init(imageNamed: HexagonType.about.imageName(), difficulty: 0)
        self.type = .about
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            gameSceneDelegate.displayAbout()
        }
    }
}

/// MARK: Gameplay

// Single Tap: gives a Success upon being tapped. Failure only if time expires.
// Basic unit of the game, gives minimum points.
class SingleTapHexagon: Hexagon {

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.singleTap.imageName(), difficulty: difficulty)
        self.type = .singleTap
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.hexSuccess(hexagon: self)
        }
    }
}

// Dont Tap: gives a Success if time expires. Failure if tapped.
// Has less life time than average.
class DontTapHexagon: Hexagon {

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.dontTap.imageName(), difficulty: difficulty)
        self.type = .dontTap
        self.lifeTime = Double(max(0.6, 1.5 - 0.1 * difficulty))
        self.timeLeft = self.lifeTime
        self.points = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.hexFailure(hexagon: self)
        }
    }

    public override func update(timeElapsed: TimeInterval) {

        self.timeLeft = timeLeft - timeElapsed

        let percentage = 1 - Float(timeLeft/lifeTime)

        self.setValue(SKAttributeValue(float: percentage), forAttribute: "a_timep")
        if timeLeft <= 0 {
            self.gameSceneDelegate.hexSuccess(hexagon: self)
        }
    }
}

// Multi Tap: Must be tapped several times for a success. Failure if time expires.
class MultiTapHexagon: Hexagon {

    private var animateAction: SKAction!
    private let numberLabel: SKLabelNode = SKLabelNode()
    private var remainingTaps: Int = 3 {
        didSet {
            self.numberLabel.text = String(remainingTaps)
        }
    }

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.multiTap.imageName(), difficulty: difficulty)

        self.remainingTaps = max(3, Int(1.3 * difficulty))
        self.lifeTime = Double(max(2.0, 1.0 + 0.4 * difficulty))
        self.timeLeft = self.lifeTime
        self.type = .multiTap
        self.points = 5

        // This Hexagon has a number label to inform how many taps to go.
        self.addChild(numberLabel)
        self.numberLabel.verticalAlignmentMode = .center
        self.numberLabel.position = CGPoint.zero
        self.numberLabel.fontName = "Futura Medium"
        self.numberLabel.fontSize = 38
        self.numberLabel.zPosition = 0.1
        self.numberLabel.fontColor = #colorLiteral(red: 0.2391727865, green: 0.2345812321, blue: 0.2718527615, alpha: 1)
        self.numberLabel.text = String(self.remainingTaps)

        // Small animation for bringing attention to the number when it changes.
        let animation1 = SKAction.scale(by: 1.2, duration: 0)
        let animation2 = SKAction.scale(to: 1.0, duration: 0.25)
        self.animateAction = SKAction.sequence([animation1, animation2])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {

            if self.remainingTaps > 1 {
                self.remainingTaps -= 1
                self.numberLabel.run(animateAction)
            } else {
                self.state = .pressed
                self.gameSceneDelegate.hexSuccess(hexagon: self)
            }
        }
    }
}

// Neighbor Master Hexagon: Gives success if you tap the Hexagon it points towards.
// Failure if you tap on it instead. A bit of a headache all around.
class NeighborMasterHexagon: Hexagon {

    public weak var slaveHexagon: NeighborSlaveHexagon!
    private var direction: NeighboringTiles!

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.neighborMaster.imageName(), difficulty: difficulty)
        self.type = .neighborMaster
        self.points = 10
        self.lifeTime = Double(max(2.0, 1.0 + 0.4 * difficulty))
        self.timeLeft = self.lifeTime
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Draws the arrow pointing in the correct direction of the Slave
    public func setDirection(direction: NeighboringTiles) {
        self.direction = direction
        let arrowNode = SKSpriteNode(imageNamed: "Arrow White")
        arrowNode.zRotation = -CGFloat(direction.rawValue) * CGFloat(Double.pi / 3.0)
        arrowNode.zPosition = 0.1
        self.addChild(arrowNode)
    }

    public override func tap() {
        if self.state == .standby {
            self.gameSceneDelegate.hexFailure(hexagon: self)
        }
    }

    public func notify() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.hexSuccess(hexagon: self)
        }
    }
}

// Neighbor Slave Hexagon: Gives success if you tap on it.
// Failure if you tap on its Master instead. A bit of a headache all around.
class NeighborSlaveHexagon: Hexagon {

    public weak var masterHexagon: NeighborMasterHexagon!

    public static var staticAlpha: CGFloat = 1 {
        didSet {
            if staticAlpha < 0 {
                staticAlpha = 0.01
            }
        }
    }

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.neighborSlave.imageName(), difficulty: difficulty)
        self.type = .neighborSlave
        self.shader = nil
        self.alpha = NeighborSlaveHexagon.staticAlpha
        self.points = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.hexSuccess(hexagon: self)
        }
    }

    // Timer failure is disabled for this one, since the Master already does this.
    // It was considered to remove the shader as well, but then it stands too much
    // apart from the rest of the hexagons. Unless we want to be s n e a k y ;)
    public override func update(timeElapsed: TimeInterval) {
        self.timeLeft = timeLeft - timeElapsed
        let percentage = 1 - Float(timeLeft/lifeTime)
        self.setValue(SKAttributeValue(float: percentage), forAttribute: "a_timep")
    }
}

// Special Hexagon: Same as Single Tap, but faster and gives more points.
// Also appears a lot less frequently.
class SpecialHexagon: Hexagon {

    init(difficulty: CGFloat) {
        super.init(imageNamed: HexagonType.special.imageName(), difficulty: difficulty)
        self.type = .special
        self.lifeTime = Double(max(0.6, 1.1 - 0.1 * difficulty))
        self.timeLeft = self.lifeTime
        self.points = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func tap() {
        if self.state == .standby {
            self.state = .pressed
            self.gameSceneDelegate.hexSuccess(hexagon: self)
        }
    }
}
