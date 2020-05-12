//
//  ChatterUITests.swift
//  ChatterUITests
//
//  Created by Sumair Zamir on 11/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import XCTest

class ChatterUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    }
    
    func testLoginButton() throws {
        // Given
        XCUIApplication().buttons["Login"].tap()
        let loginButton = app.buttons["Login"]
        let logoutButton = app.navigationBars.buttons["Logout"]
        
        // Then
        if loginButton.isSelected {
            XCTAssertTrue(logoutButton.exists)
        }
    }
    
    func testMessageSent() throws {
        // Given
        XCUIApplication().buttons["Login"].tap()
        app.textViews.containing(.staticText, identifier:"Aa").element.tap()
        let textField = app.textViews.containing(.staticText, identifier:"Aa").element
        textField.typeText("Test message")
        app/*@START_MENU_TOKEN@*/.staticTexts["Send"]/*[[".buttons[\"Send\"].staticTexts[\"Send\"]",".staticTexts[\"Send\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let sendButton = app.staticTexts["Send"]
        let messageSent = app.collectionViews.staticTexts["Test message"]
        
        // Then
        if sendButton.isSelected {
            XCTAssertTrue(messageSent.exists)
        }
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
