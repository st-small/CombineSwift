//
//  ViewController.swift
//  SignupApp
//
//  Created by Stanly Shiyanovskiy on 23.12.2020.
//

import UIKit
import Combine

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class ViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var signUpButton: BigButton!
    
    // MARK: - Subjects
    // 1. Создали нужный Subject для отслеживания состояния
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfirmationSubject = CurrentValueSubject<String, Never>("")
    private var agreeTermsSubject = CurrentValueSubject<Bool, Never>(false)

    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formIsValid
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)

        setValidColor(field: emailAddressField, publisher: emailIsValid)
        setValidColor(field: passwordField, publisher: passwordIsValid)
        setValidColor(field: passwordConfirmationField, publisher: passwordMatchesConfirmation)

        formattedEmailAddress
            .filter { [unowned self] in $0 != emailSubject.value }
            .map { $0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
    }
    
    private func setValidColor<P: Publisher>(field: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: field)
            .store(in: &cancellables)
    }
    
    // 3. Добавляем метод для проверки значения, который будет использоваться в Publisher
    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    
    // MARK: - Publishers
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            emailIsValid,
            passwordValidAndConfirmed,
            agreeTermsSubject
            )
        .map { $0.0 && $0.1 && $0.2 }
        .eraseToAnyPublisher()
    }
    
    private var formattedEmailAddress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }
    
    // 4. Создаем Publisher для отслеживания состояния поля
    private var emailIsValid: AnyPublisher<Bool, Never> {
        formattedEmailAddress
            .map { [weak self] in self?.isValidEmail($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var passwordValidAndConfirmed: AnyPublisher<Bool, Never> {
        passwordIsValid.combineLatest(passwordMatchesConfirmation)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmationSubject)
            .map { pass, conf in
                pass == conf
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    @IBAction func emailDidChange(_ sender: Any) {
        // 2. Добавили к кнопке действие отправлять значение в Subject
        emailSubject.send(emailAddressField.text ?? "")
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        passwordSubject.send(passwordField.text ?? "")
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        passwordConfirmationSubject.send(passwordConfirmationField.text ?? "")
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
        agreeTermsSubject.send(agreeTermsSwitch.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

