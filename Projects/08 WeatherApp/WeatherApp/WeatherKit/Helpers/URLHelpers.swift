//
//  URLHelpers.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import Foundation

public extension URL {
    func appending(path: String) -> URL {
        appendingPathComponent(path, isDirectory: false)
    }
    
    func appending(queryParams: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.queryItems = queryParams.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return components.url!
    }
}
