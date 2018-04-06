//
//  CellsTests.swift
//  CellsTests
//
//  Created by Gustavo De Mello Crivelli on 07/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import XCTest
@testable import Cells

class MockDefaults: UserDefaults {

    var dict: [String: Any?] = [String: Any?]()

    override func object(forKey defaultName: String) -> Any? {
        
        return dict[defaultName] ?? nil
    }

    override func set(_ value: Int, forKey defaultName: String) {
        dict[defaultName] = value
    }
}

class CellsPersistenceTests: XCTestCase {

    var statSaverService: StatSaverService!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.statSaverService = StatSaverService()
        statSaverService.defaults = MockDefaults()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.statSaverService = nil
        super.tearDown()
    }

    func testHexagonCount() {
        // Hexagon count should increase when method called
        let currentTotal = self.statSaverService.getTotalHexagons()
        self.statSaverService.updateTotalHexagons(with: 5)
        let newTotal = self.statSaverService.getTotalHexagons()

        XCTAssertEqual(currentTotal + 5, newTotal, "Error: Total hexagon count not updated")
    }

    func testHexagonCountPositivity() {
        // Hexagon count should not decrease
        let currentTotal = self.statSaverService.getTotalHexagons()
        self.statSaverService.updateTotalHexagons(with: -5)
        let newTotal = self.statSaverService.getTotalHexagons()

        XCTAssertEqual(currentTotal, newTotal, "Error: total hexagon count decreased")
    }

    func testBestScoreUpdateBetter() {
        // Scores should be updated if better
        let currentBest = self.statSaverService.getBestScore()
        _ = self.statSaverService.updateBestScore(score: currentBest + 5)
        let newBest = self.statSaverService.getBestScore()

        XCTAssertEqual(currentBest + 5, newBest, "Error: best score not updated")
    }

    func testBestScoreUpdateWorse() {
        // Scores should not be updated if worse
        let currentBest = self.statSaverService.getBestScore()
        _ = self.statSaverService.updateBestScore(score: currentBest - 5)
        let newBest = self.statSaverService.getBestScore()

        XCTAssertEqual(currentBest, newBest, "Error: best score updated when it should not")
    }

    func testBestComboUpdateBetter() {
        // Combos should be updated if better
        let currentBest = self.statSaverService.getBestCombo()
        _ = self.statSaverService.updateBestCombo(combo: currentBest + 5)
        let newBest = self.statSaverService.getBestCombo()

        XCTAssertEqual(currentBest + 5, newBest, "Error: best combo not updated")
    }

    func testBestComboUpdateWorse() {
        // Combos should not be updated if worse
        let currentBest = self.statSaverService.getBestCombo()
        _ = self.statSaverService.updateBestCombo(combo: currentBest - 5)
        let newBest = self.statSaverService.getBestCombo()

        XCTAssertEqual(currentBest, newBest, "Error: best combo updated when it should not")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
