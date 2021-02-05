//
//  LocalSearchCompleter.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import Foundation

public protocol LocalSearchCompleter {
    func search(with query: String)
    var results: AnyPublisher<[LocalSearchCompletion], Never> { get }
}
