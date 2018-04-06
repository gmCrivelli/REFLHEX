//
//  CellsUITests.swift
//  CellsUITests
//
//  Created by Gustavo De Mello Crivelli on 07/03/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import XCTest

class CellsUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test.
        // Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your
        // tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        //let app = XCUIApplication()
        
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.tap()

        _ = app.children(matching: .window).element(boundBy: 1).children(matching: .other).element
    }
}
