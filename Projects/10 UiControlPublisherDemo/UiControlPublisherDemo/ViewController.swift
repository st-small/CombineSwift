//
//  ViewController.swift
//  UiControlPublisherDemo
//
//  Created by Stanly Shiyanovskiy on 31.12.2020.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var r: UISlider!
    @IBOutlet weak var g: UISlider!
    @IBOutlet weak var b: UISlider!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPublisher.assign(to: \.backgroundColor, on: view)
            .store(in: &cancellables)
    }
    
    var colorPublisher: AnyPublisher<UIColor?, Never> {
        Publishers.CombineLatest3(
            r.valuePublisher,
            g.valuePublisher,
            b.valuePublisher
        )
        .map { values in
            UIColor(
                red: CGFloat(values.0),
                green: CGFloat(values.1),
                blue: CGFloat(values.2), alpha: 1.0) as UIColor?
        }
        .eraseToAnyPublisher()
    }
}

extension UISlider {
    var valuePublisher: AnyPublisher<Float, Never> {
        publisher(for: .valueChanged)
            .map { $0.value }
            .merge(with: Just(value))
            .eraseToAnyPublisher()
    }
}

protocol ControlPublishable { }
extension UIControl: ControlPublishable { }
extension ControlPublishable where Self: UIControl {
    func publisher(for event: UIControl.Event) -> UIControlPublisher<Self> {
        UIControlPublisher(control: self, event: event)
    }
}

struct UIControlPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never
    
    private let control: Control
    private let event: UIControl.Event
    
    init(control: Control, event: UIControl.Event) {
        self.control = control
        self.event = event
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, control: control, event: event)
        subscriber.receive(subscription: subscription)
    }
}

extension UIControlPublisher {
    final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Control, S.Failure == Failure {
        
        private var subscriber: S?
        private let control: Control
        private var demand: Subscribers.Demand?
        
        init(subscriber: S, control: Control, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        func cancel() {
            subscriber = nil
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
        }
        
        @objc
        private func handleEvent() {
            guard
                let subscriber = subscriber,
                let demand = demand,
                demand > 0 else { return }
            let newDemand = subscriber.receive(control)
            self.demand = demand + newDemand
        }
    }
}
