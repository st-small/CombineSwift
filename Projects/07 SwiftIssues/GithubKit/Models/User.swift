//
//  User.swift
//  GithubKit
//
//  Created by Ben Scheirman on 10/21/20.
//

import Foundation

public struct User: Decodable, Identifiable {
    public let id: Int64
    public let login: String
    public let avatarUrl: URL
}
