//
//  ViewController.swift
//  KeyboardNotificationDemo
//
//  Created by Stanly Shiyanovskiy on 28.12.2020.
//

import UIKit

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var chatBar: UIView!
    @IBOutlet weak var safeAreaConstraint: NSLayoutConstraint!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        
        let willShow = nc.publisher(for: UIApplication.keyboardWillShowNotification)
            .extractKeyboardInfo()
            
        let willHide = nc.publisher(for: UIApplication.keyboardWillHideNotification).extractKeyboardInfo()
            
        willShow
            .map {
                (offset: -$0.bounds.height, duration: $0.duration, curve: $0.curve)
            }
            .merge(with: willHide.map {
                (offset: 0, duration: $0.duration, curve: $0.curve)
            })
            .sink { [unowned self] params in
                let animator = UIViewPropertyAnimator(duration: params.duration, curve: params.curve) {
                    safeAreaConstraint.constant = params.offset
                    view.layoutIfNeeded()
                }
                animator.startAnimation()
            }.store(in: &cancellables)
    }

    @IBAction func sendTapped(_ sender: Any) {
        view.endEditing(true)
    }
}

struct KeyboardInfo {
    let bounds: CGRect
    let duration: TimeInterval
    let curve: UIView.AnimationCurve
}

extension Publisher where Output == Notification, Failure == Never {
    func extractKeyboardInfo() -> AnyPublisher<KeyboardInfo, Never> {
        map { notification in
            let bounds = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
            
            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            let curve = ((notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue).flatMap { UIView.AnimationCurve(rawValue: $0) } ?? .easeInOut
            
            return KeyboardInfo(bounds: bounds, duration: duration, curve: curve)
        }
        .eraseToAnyPublisher()
    }
}
