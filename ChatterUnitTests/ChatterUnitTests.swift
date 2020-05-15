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
    
    var loginViewModel = LoginViewModel()
    var chatViewModel = ChatViewModel()
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testGetDisplayName() throws {
        
        let expect = expectation(description: "login and get display name")
        
        loginViewModel.userEmail = "3@3.com"
        loginViewModel.userPassword = "123456"
        
        loginViewModel.login { (success, error) in
            if success {
                self.chatViewModel.getCurrentUserData { (success, error) in
                    if success {
                        XCTAssertEqual(self.chatViewModel.userDisplayName, "testing1")
                        expect.fulfill()
                    } else {
                        print(error!)
                        expect.fulfill()
                    }
                }
            } else {
                print(error!)
                expect.fulfill()
            }
        }
        
        wait(for: [expect], timeout: 5)
        
    }
    
    func testPerformanceExample() throws {
        measure {
        }
    }
    
}
