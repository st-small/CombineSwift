import Combine

// Sink
// Assign

// MARK: - Sink
func sinkExampleManual() {
    let publisher = [1, 3, 5, 8, 11].publisher
    
    let subscriber = Subscribers.Sink<Int, Never> { completion in
        print(completion)
    } receiveValue: { value in
        print(value)
    }

    publisher.subscribe(subscriber)
}

//sinkExampleManual()

func sinkExampleShorthand() {
    let publisher = [1, 3, 5, 8, 11].publisher
    
    publisher.sink { completion in
        print(completion)
    } receiveValue: { value in
        print(value)
    }

}

//sinkExampleShorthand()


// MARK: - Assign
class Forum {
    var latestMessage: String = "" {
        didSet {
            print("Latest message is now \(latestMessage)")
        }
    }
}

func assignExampleManual() {
    let messages = ["Hey there", "How's it going?"].publisher
    let forum = Forum()
    
    let subscriber = Subscribers.Assign<Forum, String>(object: forum, keyPath: \.latestMessage)
    
    messages.subscribe(subscriber)
}

//assignExampleManual()

func assignExampleShorthand() {
    let messages = ["Hey there", "How's it going?"].publisher
    let forum = Forum()
    
    messages.assign(to: \.latestMessage, on: forum)
}

assignExampleShorthand()
