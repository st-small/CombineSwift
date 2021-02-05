import Foundation
import Combine
import PlaygroundSupport

func example(_ title: String, block: () -> Void) {
    print("\n--------------[\(title)]--------------")
    block()
    print("----------------------------------\n\n")
}

example("Reduce") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .reduce(0) { (sum, value) in
            sum + value
        }
        .sink { print($0) }
}

example("Count") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .count()
        .sink { print($0) }
}

example("Last") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .last()
        .sink { print($0) }
}

example("First") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .first()
        .sink { print($0) }
}

example("Output(at:)") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .output(at: 2)
        .sink { print($0) }
}

example("Max") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .max()
        .sink { print($0) }
}

example("Min") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .min()
        .sink { print($0) }
}

example("Collect") {
    let values = [1, 5, 12]
    values.publisher
        .print()
        .collect()
        .sink { print($0) }
}
