import Combine
import Foundation

struct ERROR_BAD_INPUT_CALCULATION: Error { }
struct DividedByZero: Error { }

let denominators = [4, 3, 2, 0].publisher

denominators
    .tryMap { d -> Double in
        guard d != 0 else { throw ERROR_BAD_INPUT_CALCULATION() }
        return 10.0 / Double(d)
    }
    .tryCatch { error -> Just<Double> in
        print("Got an error: \(error)")
        if error is ERROR_BAD_INPUT_CALCULATION {
            throw DividedByZero()
        } else {
            throw error
        }
    }
    .sink { completion in
        print(completion)
    } receiveValue: { value in
        print(value)
    }

