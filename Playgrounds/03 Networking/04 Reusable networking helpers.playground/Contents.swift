import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/// Retrying Failed Requests

let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!

var cancellables = Set<AnyCancellable>()

struct TemporaryIssue: Error { }

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

var simulatedErrors = 3

extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
    func simulateFakeRateLimit(when: @escaping () -> Bool) -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
        map { data, response in
            if when() {
                Swift.print("Simulating rate limit HTTP Response...")
                let newResponse = HTTPURLResponse(
                    url: response.url!,
                    statusCode: 429,
                    httpVersion: nil,
                    headerFields: nil)!
                return (data: data, response: newResponse)
            } else {
                Swift.print("No more errors...")
                return(data: data, response: response)
            }
        }
        .eraseToAnyPublisher()
    }
}

func fetchPost() -> AnyPublisher<Post, HTTPError> {
    session.dataTaskPublisher(for: url)
        .assumeHTTP()
        .simulateFakeRateLimit(when: {
            simulatedErrors -= 1
            return simulatedErrors > 0
        })
        .responseData()
        .decoding(type: Post.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

let publisher = fetchPost()

publisher
    .print()
    .tryCatch { error -> AnyPublisher<Post, HTTPError> in
        if error.isRetriable {
            print("RETRYING...")
            return publisher.retry(2).eraseToAnyPublisher()
        } else {
            throw error
        }
    }
    .sink(
        receiveCompletion: { print($0) },
        receiveValue: { print($0) })
    .store(in: &cancellables)
