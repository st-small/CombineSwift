//
//  GithubAPI.swift
//  GithubKit
//
//  Created by Ben Scheirman on 10/21/20.
//

import Foundation
import Combine

public struct GithubAPI {
    static var jsonDecoder: JSONDecoder = {
       let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    public init() {
    }
    
    public func fetch<Model: Decodable>(_ endpoint: String, decoding: Model.Type) -> AnyPublisher<Model, HTTPError> {
        let url = URL(string: "https://api.github.com/\(endpoint)")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .assumeHTTP()
            .responseData()
            .decoding(type: Model.self, decoder: Self.jsonDecoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
