import Foundation
import Combine

let publisher1 = [1, 2, 3].publisher
    .setFailureType(to: Error.self)
let subject = PassthroughSubject<Int, Error>()


enum FriendlyErrors: Error {
    case unableToConnect
    case other(URLError)
}

let networkPublisher = PassthroughSubject<String, URLError>()

let pub = networkPublisher
    .mapError { error -> FriendlyErrors in
        switch error {
        case URLError.badURL,
             URLError.cannotConnectToHost,
             URLError.notConnectedToInternet,
             URLError.networkConnectionLost:
            return FriendlyErrors.unableToConnect
            
        default:
            return FriendlyErrors.other(error)
        }
    }

print(type(of: pub).Output)
print(type(of: pub).Failure)

let pub2 = networkPublisher.assertNoFailure()
print(type(of: pub2).Failure)
