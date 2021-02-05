//
//  IssuesViewModel.swift
//  SwiftIssues
//
//  Created by Stanly Shiyanovskiy on 28.12.2020.
//

import SwiftUI
import Combine

struct IdentifiableError<E: Error>: Identifiable {
    let id = UUID()
    let error: E
}

class IssuesViewModel: ObservableObject {
    
    private let api = GithubAPI()
    
    @Published var issues: [IssueRowModel] = []
    @Published var isLoading = false
    @Published var error: IdentifiableError<HTTPError>?
    
    init() {
        fetch()
    }
    
    func fetch() {
        error = nil
        api.fetch("repos/apple/swift/issues", decoding: [Issue].self)
            //.delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { _ in
                    self.isLoading = true
                },
                receiveCompletion: { _ in
                    self.isLoading = false
                },
                receiveCancel: {
                    self.isLoading = false
                })
            .catch { error -> Just<[Issue]> in
                self.error = IdentifiableError(error: error)
                return Just([])
            }
            .flatMap { $0.publisher }
            .map { IssueRowModel(issue: $0) }
            .collect()
            .assign(to: &$issues)
    }
}
