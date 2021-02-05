//
//  DiceViewModel.swift
//  HandlingErrors
//
//  Created by Stanly Shiyanovskiy on 23.12.2020.
//

import UIKit
import Combine

class DiceViewModel {
    private static var unknownDiceImage = UIImage(systemName: "questionmark.square.fill")!
    
    @Published
    private(set) var isRolling = false
    
    @Published
    private(set) var diceImage: UIImage = unknownDiceImage
    
    // 6. Создаем переменную, которая будет хранить текущее значение кости
    @Published
    private var diceValue: Int?
    
    // 7. Создаем переменную для отображения алерта с ошибкой
    @Published
    private(set) var error: DiceError?
    
    enum DiceError: Error {
        case rolledOffTable
    }
    
    // 5. Издатель (Subject) для передачи сигнала, что нужно запустить кость
    private var rollSubject = PassthroughSubject<Void, Never>()
    
    init() {
        rollSubject
            .flatMap { [unowned self] in
                roll()
                    .handleEvents(
                        receiveSubscription: { _ in
                            error = nil
                            isRolling = true
                        },
                        receiveCompletion: { _ in
                            isRolling = false
                        },
                        receiveCancel: {
                            isRolling = false
                        })
                    .map { $0 as Int? }
                    .catch { error -> Just<Int?> in
                        print("Error: \(error)")
                        self.error = error
                        return Just(nil)
                    }
            }
            .assign(to: &$diceValue)
        
        $diceValue
            .map { [unowned self] in diceImage(for: $0) }
            .assign(to: &$diceImage)
    }
    
    // 4. Метод, который будет вызываться снаружи, чтобы запустить итерацию для кости
    private func roll() -> AnyPublisher<Int, DiceError> {
        Future { promise in
            if Int.random(in: 1...4) == 1 {
                promise(.failure(DiceError.rolledOffTable))
            } else {
                let value = Int.random(in: 1...6)
                promise(.success(value))
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    public func rollDice() {
        rollSubject.send()
    }
    
    private func diceImage(for value: Int?) -> UIImage {
        switch value {
        case 1: return UIImage(named: "dice-one")!
        case 2: return UIImage(named: "dice-two")!
        case 3: return UIImage(named: "dice-three")!
        case 4: return UIImage(named: "dice-four")!
        case 5: return UIImage(named: "dice-five")!
        case 6: return UIImage(named: "dice-six")!
        default:
            return Self.unknownDiceImage
        }
    }
}
