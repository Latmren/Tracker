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

private enum Section: Int, CaseIterable {
    case name
    case settings
    case emoji
    case color
}

class NewTrackerViewController: UIViewController {

    //MARK: - Properties

    weak var delegate: TrackerCreationDelegate?

    private let screenTitle: String
    private let showsSchedule: Bool

    private let sectionSpacing: CGFloat = 16
    private let collectionHeaderHeight: CGFloat = 32

    private var isNameOverLimit = false

    private var selectedEmoji: String?
    private var selectedColor: UIColor?
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
        navigationItem.hidesBackButton = true

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

        let isEmojiSelected = selectedEmoji != nil

        let isColorSelected = selectedColor != nil

        let canCreate =
            isNameValid && isScheduleValid && isEmojiSelected && isColorSelected

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
            !title.isEmpty,
            let selectedEmoji,
            let selectedColor
        else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
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
        Section.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        guard let tableSection = Section(rawValue: section) else {
            return 0
        }

        switch tableSection {
        case .name: return 1

        case .settings: return showsSchedule ? 2 : 1

        case .emoji: return 1

        case .color: return 1

        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return 75
        }

        switch section {
        case .emoji, .color:
            return 200

        case .name, .settings:
            return 75
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let tableSection = Section(rawValue: indexPath.section) else {
            assertionFailure("Unknown table section")
            return UITableViewCell()
        }

        switch tableSection {
        case .name:

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

        case .settings:

            let cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: nil
            )

            cell.backgroundColor = .ypBackgroundDay
            
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
            
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = .ypBlackDay

            cell.detailTextLabel?.font = .systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .ypGray

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

        case .emoji:
            let cell = CollectionTableViewCell(
                type: .emoji,
                reuseIdentifier: nil
            )

            cell.onEmojiSelected = { [weak self] emoji in
                self?.selectedEmoji = emoji
                self?.updateCreateButtonState()
            }

            return cell

        case .color:
            let cell = CollectionTableViewCell(
                type: .color,
                reuseIdentifier: nil
            )

            cell.onColorSelected = { [weak self] color in
                self?.selectedColor = color
                self?.updateCreateButtonState()
            }

            return cell
        }

    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard let tableSection = Section(rawValue: indexPath.section) else {
            return
        }

        switch tableSection {
        case .settings:
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
        case .name, .emoji, .color:
            break
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard let tableSection = Section(rawValue: section) else {
            return nil
        }

        switch tableSection {
        case .name:
            return nameLimitLabel

        default:
            return nil
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {

        guard let tableSection = Section(rawValue: section) else {
            return 0
        }

        switch tableSection {
        case .name: return isNameOverLimit ? 40 : 8
        case .settings: return 16
        case .color, .emoji: return 0
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {

        guard let tableSection = Section(rawValue: section) else {
            return nil
        }

        switch tableSection {
        case .emoji, .color:
            let label = UILabel()

            label.text = tableSection == .emoji ? "Emoji" : "Цвет"
            label.font = .systemFont(ofSize: 19, weight: .bold)
            label.textColor = .ypBlackDay

            let container = UIView()
            container.backgroundColor = .ypWhite

            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(
                    equalTo: container.leadingAnchor,
                    constant: 16
                ),
                label.topAnchor.constraint(
                    equalTo: container.topAnchor,
                    constant: 10
                ),
            ])

            return container

        case .name, .settings:
            return nil
        }
    }
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {

        guard let tableSection = Section(rawValue: section) else {
            return 0
        }

        switch tableSection {
        case .emoji, .color:
            return collectionHeaderHeight

        case .name, .settings:
            return sectionSpacing
        }
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {

        guard let section = Section(rawValue: indexPath.section) else {
            return nil
        }

        switch section {
        case .settings:
            return indexPath

        case .name, .emoji, .color:
            return nil
        }
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
