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

enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkError(Error)
    case decodingError(DecodingError)
    
    var isRetriable: Bool {
        switch self {
        case .decodingError: return false
            
        case .requestFailed(let status):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return [timeoutStatus, rateLimitStatus].contains(status)
            
        case .nonHTTPResponse, .serverError, .networkError:
            return true
        }
    }
}

extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
        tryMap { (data: Data, response: URLResponse) -> (Data, HTTPURLResponse) in
            guard let http = response as? HTTPURLResponse else {
                throw HTTPError.nonHTTPResponse
            }
            return (data, http)
        }
        .mapError { error in
            if error is HTTPError {
                return error as! HTTPError
            } else {
                return HTTPError.networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
}

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
        .assumeHTTP() // Output is (Data, HTTPURLResponse)
                      // Failure is HTTPError
        .simulateFakeRateLimit(when: {
            simulatedErrors -= 1
            return simulatedErrors > 0
        })
        .tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200: return data
            case 400...499:
                throw HTTPError.requestFailed(response.statusCode)
            case 500...599:
                throw HTTPError.serverError(response.statusCode)
            default:
                fatalError("Unhandled HTTP Response status code: \(response.statusCode)")
            }
        }
        .decode(type: Post.self, decoder: JSONDecoder())
        .mapError { error in
            if error is HTTPError {
                return error as! HTTPError
            } else {
                return HTTPError.networkError(error)
            }
        }
        .catch { (error: HTTPError) -> AnyPublisher<Post, HTTPError> in
            print("Delaying for error...")
            return Fail(error: error)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
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

