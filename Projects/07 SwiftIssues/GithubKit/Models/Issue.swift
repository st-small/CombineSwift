//
//  Issue.swift
//  GithubKit
//
//  Created by Ben Scheirman on 10/21/20.
//

import Foundation

public struct Issue: Decodable, Identifiable {
    public let id: Int64
    public let title: String
    public let state: State
    public let comments: Int
    public let body: String
    public let user: User
    
    public enum State: String, Decodable {
        case open
        case closed
    }
}
