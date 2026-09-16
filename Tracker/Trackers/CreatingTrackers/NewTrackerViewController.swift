//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 15.09.2026.
//

import UIKit

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    )
}

class NewTrackerViewController: UIViewController {

    //MARK: - Properties

    weak var delegate: TrackerCreationDelegate?

    private let screenTitle: String
    private let showsSchedule: Bool

    private var isNameOverLimit = false

    private var selectedCategory = "Важное"
    private var selectedSchedule: Set<WeekDay>

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    private var shortWeekdaySymbols: [String] {
        guard
            let symbols = weekdayFormatter.shortWeekdaySymbols,
            symbols.count == 7
        else {
            return []
        }

        return Array(symbols[1...]) + [symbols[0]]
    }

    init(title: String, showSchedule: Bool, initialSchedule: Set<WeekDay>) {
        self.screenTitle = title
        self.showsSchedule = showSchedule
        self.selectedSchedule = initialSchedule
        super.init(nibName: nil, bundle: nil)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    //MARK: - UI Elements

    private let habitNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16

        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )

        tableView.backgroundColor = .ypWhite

        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = false
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let nameLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupActions()

        tableView.dataSource = self
        tableView.delegate = self
    }

    //MARK: - Setup

    private func setupView() {

        view.backgroundColor = .ypWhite

        title = screenTitle

        view.addSubview(tableView)

        view.addSubview(cancelButton)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            cancelButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            addButton.bottomAnchor.constraint(
                equalTo: cancelButton.bottomAnchor
            ),
            addButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            addButton.heightAnchor.constraint(
                equalTo: cancelButton.heightAnchor
            ),

            addButton.leadingAnchor.constraint(
                equalTo: cancelButton.trailingAnchor,
                constant: 8
            ),

            cancelButton.widthAnchor.constraint(equalTo: addButton.widthAnchor),

            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: cancelButton.topAnchor,
                constant: -16
            ),

        ])
    }

    private func setupActions() {
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
        addButton.addTarget(
            self,
            action: #selector(didTapAddButton),
            for: .touchUpInside
        )

        habitNameTextField.addTarget(
            self,
            action: #selector(didChangeHabitName),
            for: .editingChanged
        )
    }

    //MARK: - Private functions

    private func updateCreateButtonState() {
        let characterCount = habitNameTextField.text?.count ?? 0

        let isNameValid =
            characterCount > 0 && characterCount <= maxNameLength

        let isScheduleValid = !selectedSchedule.isEmpty

        let canCreate = isNameValid && isScheduleValid

        addButton.isEnabled = canCreate
        addButton.backgroundColor =
            canCreate
            ? .ypBlackDay
            : .ypGray
    }

    @objc private func didChangeHabitName() {
        let characterCount = habitNameTextField.text?.count ?? 0

        let newIsNameOverLimit = characterCount > maxNameLength

        if isNameOverLimit != newIsNameOverLimit {
            isNameOverLimit = newIsNameOverLimit

            nameLimitLabel.text =
                isNameOverLimit
                ? "Ограничение \(maxNameLength) символов"
                : nil

            tableView.performBatchUpdates(nil)
        }

        updateCreateButtonState()
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapAddButton() {
        guard
            let title = habitNameTextField.text,
            !title.isEmpty
        else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .colorSelection5,  // temporary mock
            emoji: "🙂",  // temporary mock
            schedule: selectedSchedule
        )

        delegate?.didCreateTracker(
            tracker,
            categoryTitle: selectedCategory
        )

        dismiss(animated: true)
    }

}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        2
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0: 1

        case 1: showsSchedule ? 2 : 1

        default: 0
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = UITableViewCell(
                style: .default,
                reuseIdentifier: nil
            )

            cell.backgroundColor = .ypBackgroundDay
            cell.selectionStyle = .none

            cell.contentView.addSubview(habitNameTextField)

            NSLayoutConstraint.activate([
                habitNameTextField.topAnchor.constraint(
                    equalTo: cell.contentView.topAnchor
                ),
                habitNameTextField.leadingAnchor.constraint(
                    equalTo: cell.contentView.leadingAnchor
                ),
                habitNameTextField.trailingAnchor.constraint(
                    equalTo: cell.contentView.trailingAnchor
                ),
                habitNameTextField.bottomAnchor.constraint(
                    equalTo: cell.contentView.bottomAnchor
                ),
            ])

            return cell
        }

        let cell = UITableViewCell(
            style: .subtitle,
            reuseIdentifier: nil
        )

        cell.backgroundColor = .ypBackgroundDay

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory

        case 1:
            guard showsSchedule else {
                break
            }

            cell.textLabel?.text = "Расписание"

            if selectedSchedule.count == WeekDay.allCases.count {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                cell.detailTextLabel?.text = WeekDay.allCases
                    .enumerated()
                    .filter { selectedSchedule.contains($0.element) }
                    .map { shortWeekdaySymbols[$0.offset].capitalized }
                    .joined(separator: ", ")
            }

        default:
            break
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard indexPath.section == 1 else {
            return
        }

        switch indexPath.row {
        case 0:
            break

        case 1:

            guard showsSchedule else {
                return
            }

            let viewController = ScheduleViewController(
                selectedDays: selectedSchedule
            )

            viewController.delegate = self

            navigationController?.pushViewController(
                viewController,
                animated: true
            )

        default:
            break
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard section == 0 else {
            return nil
        }

        return nameLimitLabel
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        section == 0 ? isNameOverLimit ? 40 : 8 : 0
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {

    func scheduleViewController(
        _ viewController: ScheduleViewController,
        didSelect schedule: Set<WeekDay>
    ) {
        selectedSchedule = schedule

        tableView.reloadRows(
            at: [IndexPath(row: 1, section: 1)],
            with: .none
        )

        updateCreateButtonState()
    }
}
