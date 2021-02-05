import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// Data Task Publishers

let session = URLSession.shared
let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!

func example1() {
    // Output = (data: Data, response: URLResponse)
    // Failure = URLError
    var cancellable: AnyCancellable?
    cancellable = session.dataTaskPublisher(for: url)
        .print()
        .map { $0.data }
        .replaceError(with: Data())
        .map { String(data: $0, encoding: .utf8)}
        .sink { response in
            print("Response: \(response ?? "<no body>")")
            cancellable = nil
            _ = cancellable
        }
}

enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case networkingError(URLError)
    
    var description: String {
        switch self {
        case .nonHTTPResponse:
            return "Non HTTP URL Response"
        case .requestFailed(let status):
            return "Received HTTP \(status)"
        case .networkingError(let error):
            return "Networking error: \(error)"
        }
    }
}

func fetchData() -> AnyPublisher<String?, HTTPError> {
    let url = URL(string: "https://httpbin.org/status/422")!
    return session.dataTaskPublisher(for: url)
        .mapError { HTTPError.networkingError($0) }
        .print()
        .tryMap {
            guard let http = $0.response as? HTTPURLResponse else {
                throw HTTPError.nonHTTPResponse
            }
            guard http.statusCode == 200 else {
                throw HTTPError.requestFailed(http.statusCode)
            }
            return $0.data
        }
        .mapError { $0 as! HTTPError }
        .map { String(data: $0, encoding: .utf8) }
        .eraseToAnyPublisher()
}

var cancellable = fetchData()
    .catch { (error: HTTPError) -> Just<String?> in
        print("🛑 \(error.description)")
        return Just(nil)
    }
    .sink {
        if let body = $0 {
            print(body)
        }
    }
