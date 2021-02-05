import Combine
import Foundation

extension Publishers {
    struct Amb<First: Publisher, Second: Publisher>: Publisher
    where First.Output == Second.Output, First.Failure == Second.Failure
    {
        
        typealias Output = First.Output
        typealias Failure = First.Failure
        
        let first: First
        let second: Second
        
        init(first: First, second: Second) {
            self.first = first
            self.second = second
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let sub = Subscription(first: first, second: second, subscriber: subscriber)
            subscriber.receive(subscription: sub)
        }
    }
}

private extension Publishers.Amb {
    final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        
        let first: First
        let second: Second
        var subscriber: S?
        var winner: Winner? {
            didSet {
                if let w = winner {
                    switch w {
                    case .first:
                        sink2?.cancel()
                        sink2 = nil
                    case .second:
                        sink1?.cancel()
                        sink1 = nil
                    }
                }
            }
        }
        
        var sink1: Subscribers.Sink<Output, Failure>?
        var sink2: Subscribers.Sink<Output, Failure>?
        
        var demand: Subscribers.Demand?
        
        init(first: First, second: Second, subscriber: S) {
            self.first = first
            self.second = second
            self.subscriber = subscriber
        }
        
        private func startSinks() {
            sink1 = buildSink(winner: .first)
            sink2 = buildSink(winner: .second)
            
            first.print("First").subscribe(sink1!)
            second.print("Second").subscribe(sink2!)
        }
        
        private func buildSink(winner: Winner) -> Subscribers.Sink<Output, Failure> {
            Subscribers.Sink(receiveCompletion: { [unowned self] completion in
                dispatch({
                    subscriber?.receive(completion: completion)
                }, if: winner)
            }, receiveValue: { [unowned self] value in
                dispatch({
                    guard let demand = demand, demand > 0 else { return }
                    guard let subscriber = subscriber else { return }
                    self.demand = demand + subscriber.receive(value)
                }, if: winner)
            })
        }
        
        private func dispatch(_ block: () -> Void, if winner: Winner) {
            if self.winner == nil {
                self.winner = winner
            }
            
            guard self.winner == winner else {
                return
            }
            
            block()
        }
        
        func cancel() {
            sink1?.cancel()
            sink1 = nil
            
            sink2?.cancel()
            sink2 = nil
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else { return }
            self.demand = demand
            if sink1 == nil {
                startSinks()
            }
        }
    }
    
    enum Winner {
        case first
        case second
    }
}

extension Publisher {
    func amb<Other: Publisher>(_ other: Other) -> Publishers.Amb<Self, Other> where Other.Output == Output, Other.Failure == Failure {
        Publishers.Amb(first: self, second: other)
    }
}

let sub1 = PassthroughSubject<Int, Never>()
let sub2 = PassthroughSubject<Int, Never>()
let sub3 = PassthroughSubject<Int, Never>()

//let amb = Publishers.Amb(first: sub1, second: sub2)
//amb.sink { print("---> \($0)") }

sub1.amb(sub2.amb(sub3)).sink { print("---> \($0)") }
sub3.send(100)
sub1.send(1)
sub2.send(10)
sub2.send(20)
sub3.send(200)
sub3.send(300)
sub1.send(2)
sub2.send(completion: .finished)
sub1.send(completion: .finished)
sub3.send(completion: .finished)
