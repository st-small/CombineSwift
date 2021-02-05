//
//  SignupViewModel.swift
//  SignupApp
//
//  Created by Stanly Shiyanovskiy on 28.12.2020.
//

import Combine
import UIKit

public final class SignupViewModel {
    
    // MARK: - Subjects
    @Published
    public var email = ""
    
    @Published
    public var password = ""
    
    @Published
    public var passwordConfirmation = ""
    
    @Published
    public var agreeTerms = false
    
    // MARK: - UIState
    @Published
    public var emailFieldTextColor: UIColor?
    
    @Published
    public var passwordFieldTextColor: UIColor?
    
    @Published
    public var passwordConfirmationFieldTextColor: UIColor?
    
    @Published
    public var signUpButtonEnabled = false
    
    public init() {
        setupPipeline()
    }
    
    private func setupPipeline() {
        configureEmailAddressBehavior()
        configurePasswordBehavior()
        configureSignUpButtonBehavior()
    }
    
    private func configureEmailAddressBehavior() {
        // format email address
        formattedEmailAddress
            .removeDuplicates()
            .assign(to: &$email)
        
        // set the text color to red when invalid
        emailIsValid
            .mapToFieldInputColor()
            .assign(to: &$emailFieldTextColor)
    }
    
    private func configurePasswordBehavior() {
        passwordIsValid
            .mapToFieldInputColor()
            .assign(to: &$passwordFieldTextColor)
        
        passwordMatchesConfirmation
            .mapToFieldInputColor()
            .assign(to: &$passwordConfirmationFieldTextColor)
    }
    
    private func configureSignUpButtonBehavior() {
        formIsValid.assign(to: &$signUpButtonEnabled)
    }
    
    // MARK: - Publishers
    public var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            emailIsValid,
            passwordValidAndConfirmed,
            $agreeTerms
            )
        .map { $0.0 && $0.1 && $0.2 }
        .eraseToAnyPublisher()
    }
    
    public var formattedEmailAddress: AnyPublisher<String, Never> {
        $email
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }
    
    public var emailIsValid: AnyPublisher<Bool, Never> {
        formattedEmailAddress
            .map { [weak self] in self?.isValidEmail($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    public var passwordValidAndConfirmed: AnyPublisher<Bool, Never> {
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    public var passwordIsValid: AnyPublisher<Bool, Never> {
        $password
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    public var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        $password.combineLatest($passwordConfirmation)
            .map { pass, conf in
                pass == conf
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}

extension Publisher where Output == Bool, Failure == Never {
    func mapToFieldInputColor() -> AnyPublisher<UIColor?, Never> {
        map { isValid -> UIColor? in
            isValid ? .label : .systemRed
        }
        .eraseToAnyPublisher()
    }
}
