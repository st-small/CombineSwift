import Combine
import Foundation

struct ShinyOperator<Upstream: Publisher>: Publisher {
    
    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure
    
    let upstream: Upstream
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let op = Operator(downstream: subscriber)
        upstream.subscribe(op)
    }
}

extension ShinyOperator {
    final class Operator<S: Subscriber, Input>: Subscription, Subscriber where S.Input == Output, S.Failure == Failure, Input == S.Input {
        
        typealias Input = S.Input
        typealias Failure = S.Failure
        
        var downstream: S?
        var upstream: Subscription?
        
        init(downstream: S?) {
            self.downstream = downstream
        }
        
        // MARK: - Subscription
        
        func request(_ demand: Subscribers.Demand) {
            upstream?.request(demand)
        }
        
        func cancel() {
            upstream?.cancel()
            upstream = nil
            downstream = nil
        }
        
        // MARK: - Subscriber
        
        func receive(subscription: Subscription) {
            upstream = subscription
            downstream?.receive(subscription: self)
        }
        
        func receive(_ input: S.Input) -> Subscribers.Demand {
            Swift.print("✨\(input)✨")
            return downstream?.receive(input) ?? .max(0)
        }
        
        func receive(completion: Subscribers.Completion<S.Failure>) {
            downstream?.receive(completion: completion)
            upstream = nil
            downstream = nil
        }
    }
}

extension Publisher {
    func shiny() -> ShinyOperator<Self> {
        ShinyOperator(upstream: self)
    }
}

_ = [1, 2, 3, 4, 5]
    .publisher
    .shiny()
    .sink { value in
        print(value)
    }
