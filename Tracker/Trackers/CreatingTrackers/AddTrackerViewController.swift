//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 14.09.2026.
//

import UIKit

final class AddTrackerViewController: UIViewController {
    //MARK: - Properties
    
    weak var delegate: TrackerCreationDelegate?
    
    //MARK: - UI Elements

    private let habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupActions()
    }

    //MARK: - Setup

    private func setupView() {
        view.backgroundColor = .ypWhite
        title = "Создание трекера"

        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)

        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            habitButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            habitButton.heightAnchor.constraint(equalToConstant: 60),

            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            irregularEventButton.leadingAnchor.constraint(
                equalTo: habitButton.leadingAnchor,
            ),
            irregularEventButton.trailingAnchor.constraint(
                equalTo: habitButton.trailingAnchor,
            ),

            irregularEventButton.topAnchor.constraint(
                equalTo: habitButton.bottomAnchor,
                constant: 16
            ),

            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func setupActions() {
        habitButton.addTarget(
            self,
            action: #selector(didTapHabitButton),
            for: .touchUpInside
        )
        irregularEventButton.addTarget(
            self,
            action: #selector(didTapIrregularEventButton),
            for: .touchUpInside
        )
    }
    
    @objc private func didTapHabitButton() {
        let newHabitViewController = NewHabitViewController()
        
        newHabitViewController.delegate = delegate
        
        navigationController?.pushViewController(newHabitViewController, animated: true)
    }
    
    @objc private func didTapIrregularEventButton() {
        let newIrregularEventViewController = NewIrregularEventViewController()
        
        newIrregularEventViewController.delegate = delegate
        
        navigationController?.pushViewController(newIrregularEventViewController, animated: true)
    }
}
