//
//  TestLocalSearch.swift
//  WeatherAppTests
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import Foundation
@testable import WeatherApp

class TestLocalSearch: LocalSearchCompleter {
    
    var queries: [String] = []
    
    func search(with query: String) {
        queries.append(query)
    }
    
    var subject = PassthroughSubject<[LocalSearchCompletion], Never>()
    
    var results: AnyPublisher<[LocalSearchCompletion], Never> {
        subject.eraseToAnyPublisher()
    }
}
