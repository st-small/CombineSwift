import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// Subscribe(on: )

print("---------- Start ------------")
let c = Just(1)
    .subscribe(on: DispatchQueue.main)
    .map { x in
        sleep(1)
        print("MAP - Thread: \(Thread.current)")
    }
    .subscribe(on: DispatchQueue.global())
    .sink { x in
        print("x: \(x), Thread: \(Thread.current)")
    }
print("---------- Done ------------")
