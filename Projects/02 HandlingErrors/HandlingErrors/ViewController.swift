//
//  ViewController.swift
//  HandlingErrors
//
//  Created by Stanly Shiyanovskiy on 23.12.2020.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var diceImage: UIImageView!
    @IBOutlet weak var rollDiceButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = DiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiceImage()
        
        // Setup Subscriptions
        // 1. Подписываемся на получение актуальной картинки для кости
        viewModel.$diceImage
            .map { $0 as UIImage? }
            .assign(to: \.image, on: diceImage)
            .store(in: &cancellables)
        
        // 2. Подписываемся на получение состояния кости, чтобы отключать кнопку запуска
        viewModel.$isRolling
            .map { !$0 }
            .assign(to: \.isEnabled, on: rollDiceButton)
            .store(in: &cancellables)
        
        // 3. Подписываемся на получение состояния кости, чтобы менять альфу
        viewModel.$isRolling
            .sink { [unowned self] isRolling in
                UIView.animate(withDuration: 0.5) {
                    diceImage.alpha = isRolling ? 0.5 : 1.0
                    diceImage.transform = isRolling ? CGAffineTransform(scaleX: 0.5, y: 0.5) : .identity
                }
            }
            .store(in: &cancellables)
        
        // 7. Подписываемся на получение состояния ошибки, чтобы показать алерт
        viewModel.$error
            .compactMap { $0 }
            .sink { [unowned self] error in
                let alert = UIAlertController(title: "Dice Error", message: "\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Reroll", style: .default, handler: { _ in
                    rollDiceTapped(self)
                }))
                present(alert, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
    
    private func configureDiceImage() {
        diceImage.layer.shadowColor = UIColor.black.cgColor
        diceImage.layer.shadowOpacity = 0.25
        diceImage.layer.shadowRadius = 2
        diceImage.layer.shadowOffset = .zero
    }
    
    @IBAction func rollDiceTapped(_ sender: Any) {
        // Roll Dice
        viewModel.rollDice()
    }
}

