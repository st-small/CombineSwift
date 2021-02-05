import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// Record Publisher

enum CustomError: Int, Error, Codable {
    case outOfGas
}

var recording = Record<Int, CustomError>.Recording()

let pub = [1, 2, 3].publisher
    .setFailureType(to: CustomError.self)
    .sink { completion in
        recording.receive(completion: completion)
    } receiveValue: { value in
        recording.receive(value)
    }

//let recPub = Record(recording: recording)
let recPub = Record<Int, CustomError>(output: [5, 6, 7], completion: .failure(.outOfGas))

recPub
    .sink(
        receiveCompletion: { print($0) },
        receiveValue: { print($0) })

let encoder = JSONEncoder()
let data = try! encoder.encode(recPub)
print(String(data: data, encoding: .utf8)!)

let decoder = JSONDecoder()
let recPub2 = try! decoder.decode(Record<Int, CustomError>.self, from: data)

recPub2
    .sink(
        receiveCompletion: { print($0) },
        receiveValue: { print($0) })
