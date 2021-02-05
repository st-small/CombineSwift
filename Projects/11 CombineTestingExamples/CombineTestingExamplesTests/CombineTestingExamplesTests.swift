//
//  CombineTestingExamplesTests.swift
//  CombineTestingExamplesTests
//
//  Created by Stanly Shiyanovskiy on 04.01.2021.
//

import Combine
import XCTest
@testable import CombineTestingExamples

class CombineTestingExamplesTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cancellables = nil
    }

    func testSimplePublisher() {
        let pub = [1, 2, 3].publisher
        
        var values: [Int] = []
        var completion: Subscribers.Completion<Never>?
        
        _ = pub.sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { values.append($0) })
        
        XCTAssertEqual(values, [1, 2, 3])
        XCTAssertNotNil(completion)
        XCTAssertEqual(completion, .finished)
    }

    func testFilter() {
        let pub = [1, 2, 3, 4, 5, 6].publisher
        
        var values: [Int] = []
        var completion: Subscribers.Completion<Never>?
        
        _ = pub
            .filter { $0.isMultiple(of: 2) }
            .sink(
            receiveCompletion: { completion = $0 },
            receiveValue: { values.append($0) })
        
        XCTAssertEqual(values, [2, 4, 6])
        XCTAssertNotNil(completion)
        XCTAssertEqual(completion, .finished)
    }
    
    func testFuture() {
        var callCount = 0
        let pub = Deferred {
            Future<String, Never> { promise in
                callCount += 1
                promise(.success("OK"))
            }
        }
        .share()
        .makeConnectable()
        
        XCTAssertEqual(callCount, 0)
        
        var value1: String?
        var value2: String?
        pub.sink { value1 = $0 }.store(in: &cancellables)
        pub.sink { value2 = $0 }.store(in: &cancellables)
        
        _ = pub.connect()
        
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(value1, "OK")
        XCTAssertEqual(value2, "OK")
    }
    
    func testValuesThenFailure() throws {
        struct TestError: Error { }
        
        let subject = PassthroughSubject<Int, TestError>()
        
        var values: [Int] = []
        var completion: Subscribers.Completion<TestError>?
        
        subject.sink { completion = $0 } receiveValue: { values.append($0) }
            .store(in: &cancellables)

        subject.send(5)
        subject.send(6)
        subject.send(7)
        subject.send(completion: .failure(TestError()))
        
        switch try XCTUnwrap(completion) {
        case .finished: XCTFail("Expected to get an error")
        case .failure(let error):
            XCTAssertEqual(error.localizedDescription, TestError().localizedDescription)
        }
        
        XCTAssertEqual(values, [5, 6, 7])
    }
}
