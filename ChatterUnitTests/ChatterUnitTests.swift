//
//  ChatterUnitTests.swift
//  ChatterUnitTests
//
//  Created by Sumair Zamir on 11/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import XCTest
@testable import Chatter
@testable import FirebaseAuth

class ChatterUnitTests: XCTestCase {
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    func testGetDisplayName() throws {
        // Set parameters for login
        NetworkParameters.userEmail = "3@3.com"
        NetworkParameters.userPassword = "123456"
        
        // Define an expectation
        let expect = expectation(description: "login")
        waitForExpectations(timeout: 3)
        
        // Run the async task to login
        NetworkLogic.login { (success, error) in
            if success {
                // Run the async task to get user data
                NetworkLogic.getCurrentUserData { (success, error) in
                    if success {
                        expect.fulfill()
                    } else {
                        print(error!)
                    }
                }
            } else {
                print(error!)
            }
        }
        
        // Assert the received display name to expectations
        XCTAssertEqual(NetworkParameters.userDisplayName, "testing1")
    }

    func testPerformanceExample() throws {
        measure {
        }
    }

}
