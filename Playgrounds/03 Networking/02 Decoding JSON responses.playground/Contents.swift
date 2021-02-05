import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// Decoding JSON Models

let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

var cancellables: Set<AnyCancellable> = []

session.dataTaskPublisher(for: url)
    .map { $0.data }
    .decode(type: Post.self, decoder: JSONDecoder())
    .sink { completion in
        print("Completion: \(completion)")
    } receiveValue: { post in
        print("Post: \(post.title)")
    }
    .store(in: &cancellables)

//extension Publisher where Output == Data {
//    func decode2<Item, Coder>(type: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder>
//    where Item: Decodable,
//    Coder: TopLevelDecoder,
//    Self.Output == Coder.Input
//}
