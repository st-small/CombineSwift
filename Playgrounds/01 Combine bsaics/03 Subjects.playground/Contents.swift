import Foundation
import Combine

// Subjects

// Just
// Empty
// Fail
// Publishers.Sequence
// Timer.TimerPublisher

// MARK: - PassthroughSubject

let subject = PassthroughSubject<String, Never>()
subject.sink { print("1) received \($0)") }

subject.send("message 1")
subject.send("message 2")

print("------------------")

let subject2 = PassthroughSubject<String, Never>()
subject2.sink { completion in
    print("2) \(completion)")
} receiveValue: { value in
    print("2) \(value)")
}

subject2.send("Testing completion")
subject2.send(completion: .finished)

print("------------------")

struct MyCustomError: Error { }
let subject3 = PassthroughSubject<String, MyCustomError>()
subject3.sink { completion in
    print("3) \(completion)")
} receiveValue: { value in
    print("3) \(value)")
}

subject3.send("Testing Failure")
subject3.send(completion: .failure(MyCustomError()))

print("------------------")

// MARK: - CurrentValueSubject

let wordOfTheDay = CurrentValueSubject<String, Never>("bellicose")
wordOfTheDay.sink { print("The word of the day is '\($0)'.") }
wordOfTheDay.send("erudite")

wordOfTheDay.value

wordOfTheDay.sink { print("Second subscriber received: \($0)") }
wordOfTheDay.send("cogitable")


let buttonTapSubject = PassthroughSubject<Void, Never>()
buttonTapSubject.send()
