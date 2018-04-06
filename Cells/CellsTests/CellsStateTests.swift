//
//  CellsStateTests.swift
//  CellsTests
//
//  Created by Gustavo De Mello Crivelli on 07/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import XCTest
@testable import Cells

class CellsStateTests: XCTestCase {

    var gameScene: GameScene!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        gameScene = GameScene()
        //gameScene.initialSetup()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        gameScene = nil
        super.tearDown()
    }

//    func testExample() {
//        gameScene.gameState = PausedState(gameScene: gameScene)
//        XCTAssertFalse(gameScene.pauseGameNode.isHidden)
//    }
}
