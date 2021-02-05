import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// Schedulers

DispatchQueue.global().async {
    Just(1)
        .sink { _ in
            print(Thread.current)
            print(Thread.isMainThread)
        }
}

let session = URLSession.shared
let c = session.dataTaskPublisher(for: URL(string: "https://httpbin.org")!)
    .assertNoFailure()
    .sink { _ in
        print(Thread.current)
        print(Thread.isMainThread)
    }
