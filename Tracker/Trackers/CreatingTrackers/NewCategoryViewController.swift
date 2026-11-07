//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 04.10.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: TrackerCategoryViewModel

    // MARK: - UI Elements

    private let nameTextField: UITextField = {
        let textField = UITextField()

        textField.placeholder = String(localized: .newCategoryNamePlaceholder)
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .ypBlack
        textField.backgroundColor = .ypBackground

        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing

        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 16,
                height: 0
            )
        )

        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.returnKeyType = .done

        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(String(localized: .readyButton), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)

        button.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )

        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupActions()
    }

    // MARK: - Setup

    private func setupView() {
        title = String(localized: .newCategoryTitle)
        view.backgroundColor = .ypWhite

        view.addSubview(nameTextField)
        view.addSubview(doneButton)

        navigationItem.hidesBackButton = true

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            nameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            nameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            nameTextField.heightAnchor.constraint(
                equalToConstant: 75
            ),

            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            doneButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
        ])
    }

    private func setupActions() {
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.addTarget(
            self,
            action: #selector(nameTextFieldChanged),
            for: .editingChanged
        )

        doneButton.addTarget(
            self,
            action: #selector(didTapDoneButton),
            for: .touchUpInside
        )
        
        nameTextField.addTarget(
            self,
            action: #selector(didPressReturn),
            for: .editingDidEndOnExit
        )
    }

    // MARK: - Actions

    @objc
    private func nameTextFieldChanged() {
        
        let isValid = viewModel.isCategoryNameValid(
            nameTextField.text ?? ""
        )

        doneButton.isEnabled = isValid
        doneButton.backgroundColor =
            isValid ? .ypBlack : .ypGray
    }

    @objc
    private func didTapDoneButton() {
        guard
            let text = nameTextField.text,
            viewModel.isCategoryNameValid(text)
        else {
            return
        }

        do {
            try viewModel.addCategory(title: text)

            navigationController?.popViewController(
                animated: true
            )
        } catch {
            showErrorAlert(
                message: String(localized: .categoryCreationSaveError)
            )
        }
    }
    
    @objc
    private func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        guard !nameTextField.frame.contains(location) else {
            return
        }

        nameTextField.resignFirstResponder()
    }
    
    @objc
    private func didPressReturn() {
        nameTextField.resignFirstResponder()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: String(localized: .genericErrorTitle),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: String(localized: .okButton), style: .default)
        )
        present(alert, animated: true)
    }
}
