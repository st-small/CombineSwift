import Combine
import Foundation

// Publisher
// typealias Output
// typealias Failure
// func receive<S>...
// Correctly respond to DEMAND a.k.a Back Pressure

struct BadNumberError: Error { }

struct RandomNumberPublisher: Publisher {
    typealias Output = Int
    typealias Failure = BadNumberError
    
    private let range: ClosedRange<Int>
    private let count: Int
    
    init(range: ClosedRange<Int>, count: Int) {
        self.range = range
        self.count = count
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(range: range, count: count, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension RandomNumberPublisher {
    final class Subscription<S: Subscriber>: Combine.Subscription
    where Output == S.Input, Failure == S.Failure
    {
        
        private let range: ClosedRange<Int>
        private var count: Int
        
        private var subscriber: S?
        
        init(range: ClosedRange<Int>, count: Int, subscriber: S) {
            self.range = range
            self.count = count
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            var demand = demand
            while let subscriber = subscriber, demand > 0 {
                demand -= 1
                do {
                    let value = try generateRandomNumber()
                    let newDemand = subscriber.receive(value)
                    demand += newDemand
                    count -= 1
                    if count <= 0 {
                        subscriber.receive(completion: .finished)
                        self.subscriber = nil
                    }
                } catch {
                    subscriber.receive(completion: .failure(error as! BadNumberError))
                    self.subscriber = nil
                }
            }
        }
        
        private func generateRandomNumber() throws -> Int {
            let value = Int.random(in: range)
            if value.isMultiple(of: 3) {
                throw BadNumberError()
            }
            
            return value
        }
        
        func cancel() {
            subscriber = nil
        }
    }
}

// Потоки
//RandomNumberPublisher(range: 1...100, count: 5)
//    .subscribe(on: DispatchQueue.global())
//    .receive(on: DispatchQueue.main)
//    .sink(receiveCompletion: { print($0) },
//          receiveValue: { print($0) })

// Обработка ошибок
RandomNumberPublisher(range: 1...100, count: 5)
    .print()
    .first()
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
