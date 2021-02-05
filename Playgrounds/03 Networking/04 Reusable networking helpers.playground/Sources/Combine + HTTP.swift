import Foundation
import Combine

public enum HTTPError: Error {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkError(Error)
    case decodingError(DecodingError)
    
    public var isRetriable: Bool {
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

public extension Publisher where Output == (data: Data, response: URLResponse) {
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

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {
    func responseData() -> AnyPublisher<Data, HTTPError> {
        tryMap { (data: Data, response: HTTPURLResponse) -> Data in
            switch response.statusCode {
            case 200...299: return data
            case 400...499:
                throw HTTPError.requestFailed(response.statusCode)
            case 500...599:
                throw HTTPError.serverError(response.statusCode)
            default:
                fatalError("Unhandled HTTP Response status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HTTPError }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data, Failure == HTTPError {
    func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HTTPError>
    where
        Item: Decodable,
        Coder: TopLevelDecoder,
        Self.Output == Coder.Input
    {
        decode(type: type, decoder: decoder)
            .mapError { error in
                if error is HTTPError {
                    return HTTPError.decodingError(error as! DecodingError)
                } else {
                    return HTTPError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
