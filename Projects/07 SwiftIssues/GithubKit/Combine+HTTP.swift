import Foundation
import Combine

public enum HTTPError: Error, CustomStringConvertible {
    case nonHTTPResponse
    case requestFailed(Int)
    case serverError(Int)
    case networkError(Error)
    case decodingError(DecodingError)
    
    public var isRetriable: Bool {
        switch self {
        case .decodingError:
            return false
            
        case .requestFailed(let status):
            let timeoutStatus = 408
            let rateLimitStatus = 429
            return [timeoutStatus, rateLimitStatus].contains(status)
            
        case .serverError, .networkError, .nonHTTPResponse:
            return true
        }
    }
    
    public var description: String {
        switch self {
        case .nonHTTPResponse: return "Non-HTTP response received"
        case .requestFailed(let status): return "Received HTTP \(status)"
        case .serverError(let status): return "Server Error - \(status)"
        case .networkError(let error): return "Failed to load the request: \(error)"
        case .decodingError(let decError): return "Failed to process response: \(decError)"
        }
    }
}

public extension Publisher where Output == (data: Data, response: URLResponse) {
    func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
        tryMap { (data: Data, response: URLResponse) in
            guard let http = response as? HTTPURLResponse else { throw HTTPError.nonHTTPResponse }
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
            case 200: return data
            case 400...499:
                throw HTTPError.requestFailed(response.statusCode)
            case 500...599:
                throw HTTPError.serverError(response.statusCode)
            default:
                fatalError("Unhandled HTTP Response Status code: \(response.statusCode)")
            }
        }
        .mapError { $0 as! HTTPError }
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data, Failure == HTTPError {
    func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HTTPError>
    where Item: Decodable,
    Coder: TopLevelDecoder,
    Self.Output == Coder.Input {
        decode(type: Item.self, decoder: decoder)
            .mapError {
                if $0 is HTTPError {
                    return $0 as! HTTPError
                } else {
                    let decodingError = $0 as! DecodingError
                    return HTTPError.decodingError(decodingError)
                }
            }
            .eraseToAnyPublisher()
    }
}
