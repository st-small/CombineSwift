//
//  TestEnvironments.swift
//  WeatherAppTests
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Foundation
@testable import WeatherApp

class TestEnvironments {
    
    static var worlds: [World] = [
        Current
    ]
    
    static func push() {
        let copy = worlds.last!
        worlds.append(copy)
        Current = copy
    }
    
    static func pop() {
        precondition(worlds.count > 1, "Can't remove last world")
        worlds.removeLast()
        Current = worlds.last!
    }
}
