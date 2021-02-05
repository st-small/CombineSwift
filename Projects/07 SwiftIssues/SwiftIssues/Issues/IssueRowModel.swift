//
//  IssueRowModel.swift
//  SwiftIssues
//
//  Created by Stanly Shiyanovskiy on 28.12.2020.
//

import SwiftUI
import Combine

class IssueRowModel: ObservableObject, Identifiable {
    
    private let issue: Issue
    
    var id: Int64 { issue.id }
    var title: String { issue.title }
    var author: String { issue.user.login }
    var commentCount: Int { issue.comments }
    
    static var defaultAvatar: UIImage {
        UIImage(systemName: "person.crop.circle")!
    }
    
    @Published var avatarImage: UIImage?
    
    init(issue: Issue) {
        self.issue = issue
    }
    
    func fetchAvatar() {
        URLSession.shared.dataTaskPublisher(for: issue.user.avatarUrl)
            //.delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .assumeHTTP()
            .responseData()
            .receive(on: DispatchQueue.main)
            .map { UIImage(data: $0) }
            .replaceError(with: Self.defaultAvatar)
            .assign(to: &$avatarImage)
    }
}
