import Foundation
import Combine
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

class TickTock {
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .print("Timer")
            .sink { [unowned self] _ in
                tick()
            }.store(in: &cancellables)
    }
    
    func tick() {
        print("Tick")
    }
}

var example: TickTock? = TickTock()

DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
    print("Cleaning up...")
    example = nil
}
