import Foundation
import Combine
import PlaygroundSupport

func example(_ title: String, block: () -> Void) {
    print("\n--------------[\(title)]--------------")
    block()
    print("----------------------------------\n\n")
}

example("Map") {
    let x = [1, 2, 3, 5, 8, 13].publisher
        .map { $0 * 10 }
        .sink { print($0) }
    
    [1, 2, 3].publisher
        .map { String("and-a \($0)") }
        .sink { print($0) }
}

example("Filter") {
    _ = [1, 2, 3, 5, 8, 13].publisher
        .map { $0 * 10 }
        .filter { $0 < 60 }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
}

example("Scan") {
    _ = ["b", "e", "n"].publisher
        .scan("") { (accumulated, char) -> String in
            accumulated + char
        }
        .sink { print($0) }
    
    let grades: [Double] = [98, 65, 49, 99, 100, 95]
    grades.publisher
        .scan((avg: 0.0, sum: 0.0, count: 0)) { (tuple, grade) in
            let newSum = tuple.sum + grade
            let count = tuple.count + 1
            let avg = newSum / Double(count)
            return (avg: avg, sum: newSum, count: count)
        }
        .map { $0.avg }
        .sink { print($0) }
    
    PlaygroundPage.current.needsIndefiniteExecution = true
    var timerCancellable: AnyCancellable? =
    Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .scan(0) { count, _ in
            count + 1
        }
        .sink { print($0) }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        timerCancellable = nil
        PlaygroundPage.current.needsIndefiniteExecution = false
    }
}

example("RemoveDuplicates") {
    [1, 1, 1, 1, 2, 2, 3, 4, 5, 1, 2].publisher
        .removeDuplicates()
        .sink { print($0) }
}

example("CompactMap") {
    let values: [Int?] = [1, nil, 2, nil, 3]
    let pub = values.publisher
        .compactMap { $0 }
        .sink { print($0) }
    
    ["1", "a", "2", "23", "asdaf"].publisher
        .compactMap { Int($0) }
        .sink { print($0) }
}
