//
//  SignupAppTests.swift
//  SignupAppTests
//
//  Created by Stanly Shiyanovskiy on 04.01.2021.
//

import Combine
import XCTest
@testable import SignupApp

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased


class SignupAppTests: CombineTestCase {

    var viewModel: SignupViewModel!
    
    override func setUp() {
        super.setUp()
        
        viewModel = SignupViewModel()
    }

    func testValidEmail() {
        assertPublisher(viewModel.emailIsValid, produces: true) {
            viewModel.email = "foo@bar.com"
        }
    }
    
    func testInvalidEmail() {
        assertPublisher(viewModel.emailIsValid, produces: false) {
            viewModel.email = "foo"
        }
    }
    
    func testValidPassword() {
        assertPublisher(viewModel.passwordIsValid, produces: true) {
            viewModel.password = "combineswift11"
        }
    }
    
    func testInvalidPassword() {
        assertPublisher(viewModel.passwordIsValid, produces: false) {
            viewModel.password = "combine"
        }
    }
    
    func testPasswordMatchesConfirmation() {
        assertPublisher(viewModel.passwordMatchesConfirmation.dropFirst(2), producesExactly: false, true) {
            viewModel.password = "combineswift1"
            viewModel.passwordConfirmation = "combineswift2" // --> false
            
            viewModel.passwordConfirmation = "combineswift1" // --> true
        }
    }
    
    func testFormIsValid() {
        var isValidSignal: Bool?
        viewModel.formIsValid
            .sink { isValidSignal = $0 }
            .store(in: &cancellables)
        
        viewModel.email = "invalid"
        viewModel.password = "invalid"
        viewModel.passwordConfirmation = "invalid2"
        viewModel.agreeTerms = false
        XCTAssertEqual(isValidSignal, false)
        
        viewModel.email = "tcook@apple.com"
        viewModel.password = "combineswift1"
        viewModel.passwordConfirmation = "combineswift1"
        viewModel.agreeTerms = true
        XCTAssertEqual(isValidSignal, true)
    }
}
