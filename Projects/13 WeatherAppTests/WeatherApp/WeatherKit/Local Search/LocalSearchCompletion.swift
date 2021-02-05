//
//  LocalSearchCompletion.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Foundation

public struct LocalSearchCompletion: Identifiable, Equatable, Hashable {
    
    public let id = UUID()
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
