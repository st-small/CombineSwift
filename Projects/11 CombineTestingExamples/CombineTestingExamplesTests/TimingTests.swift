//
//  TimingTests.swift
//  CombineTestingExamplesTests
//
//  Created by Stanly Shiyanovskiy on 04.01.2021.
//

import Combine
import CombineSchedulers
import Foundation
import XCTest

class CombineTestCase: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
    }
}

class TimingTests: CombineTestCase {
    
    private func simpleValuePublisher<S: Scheduler>(scheduler: S) -> AnyPublisher<Int, Never> {
        Just(1)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func delayedPublisher<Seq: Sequence>(values: Seq, scheduler: AnySchedulerOf<DispatchQueue>) -> AnyPublisher<Seq.Element, Never> {
        values.publisher
            .flatMap(maxPublishers: .max(1)) {
                Just($0)
                    .delay(for: .seconds(1), scheduler: scheduler)
            }
            .eraseToAnyPublisher()
    }
    
    func testReceiveOn() {
        let pub = simpleValuePublisher(scheduler: DispatchQueue.immediateScheduler)
        
        var value: Int?
        pub
            .sink { value = $0 }
            .store(in: &cancellables)
        
        XCTAssertEqual(value, 1)
    }
    
    func testDelay() {
        let scheduler = DispatchQueue.testScheduler
        let pub = delayedPublisher(values: (1...30), scheduler: scheduler.eraseToAnyScheduler())
        
        var count = 0
        pub
            .sink { _ in count += 1 }
            .store(in: &cancellables)
        
        scheduler.advance(by: 1)
        XCTAssertEqual(count, 1)
        
        scheduler.advance(by: 1)
        XCTAssertEqual(count, 2)
        
        scheduler.advance(by: 10)
        XCTAssertEqual(count, 12)
        
        scheduler.advance(by: 20)
        XCTAssertEqual(count, 30)
    }
}
