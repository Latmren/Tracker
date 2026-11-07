//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 15.09.2026.
//

import UIKit

protocol TrackerFormDelegate: AnyObject {
    func didCreateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws
    func didUpdateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws
}

private enum Section: Int, CaseIterable {
    case name
    case settings
    case emoji
    case color
}

class NewTrackerViewController: UIViewController {

    //MARK: - Properties

    weak var delegate: TrackerFormDelegate?

    private let newTrackerViewModel: NewTrackerViewModel

    private let categoryStore: TrackerCategoryStore

    private let screenTitle: String
    private let showsSchedule: Bool

    private let sectionSpacing: CGFloat = 16
    private let collectionHeaderHeight: CGFloat = 32

    private let daysFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()

    private var isNameOverLimit = false

    init(
        title: String,
        showSchedule: Bool,
        categoryStore: TrackerCategoryStore,
        newTrackerViewModel: NewTrackerViewModel
    ) {
        self.screenTitle = title
        self.showsSchedule = showSchedule
        self.categoryStore = categoryStore
        self.newTrackerViewModel = newTrackerViewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    //MARK: - UI Elements

    private let habitNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = String(localized: .newTrackerNamePlaceholder)
        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: 0)
        )

        textField.clearButtonMode = .whileEditing
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        
        textField.returnKeyType = .done

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
        button.setTitle(String(localized: .cancelButton), for: .normal)
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
        button.setTitle(String(localized: .createButton), for: .normal)
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

        habitNameTextField.text = newTrackerViewModel.trackerName

        tableView.dataSource = self
        tableView.delegate = self

        bindViewModel()
        updateCreateButtonState()
    }

    //MARK: - Setup

    private func setupView() {

        view.backgroundColor = .ypWhite

        title = screenTitle
        navigationItem.hidesBackButton = true

        view.addSubview(tableView)

        view.addSubview(cancelButton)
        view.addSubview(addButton)
        
        tableView.keyboardDismissMode = .onDrag

        if newTrackerViewModel.isEditing {
            addButton.setTitle(String(localized: .saveButton), for: .normal)
        }

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
        habitNameTextField.addTarget(
            self,
            action: #selector(didPressReturn),
            for: .editingDidEndOnExit
        )
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

    //MARK: - Private Methods

    private func bindViewModel() {
        newTrackerViewModel.onFormChanged = { [weak self] in
            self?.updateNameLimitUI()
            self?.updateCreateButtonState()
        }
    }

    private func updateNameLimitUI() {
        let newIsNameOverLimit = newTrackerViewModel.isNameOverLimit

        if isNameOverLimit != newIsNameOverLimit {
            isNameOverLimit = newIsNameOverLimit

            nameLimitLabel.text =
                isNameOverLimit
                ? String(
                    localized: .tooMuchSymbolsTitle(
                        maxNameLength: maxNameLength
                    )
                )
                : nil

            tableView.performBatchUpdates(nil)
        }
    }

    private func updateCreateButtonState() {

        let canCreate = newTrackerViewModel.canCreate
        addButton.isEnabled = canCreate
        addButton.backgroundColor =
            canCreate
            ? .ypBlack
            : .ypGray
    }

    private func openCategorySelection() {
        let viewModel = TrackerCategoryViewModel(
            categoryStore: categoryStore,
            selectedCategoryTitle: newTrackerViewModel.selectedCategory
        )

        let viewController = CategoryViewController(
            viewModel: viewModel
        )

        viewController.onCategorySelected = { [weak self] title in
            guard let self else { return }

            self.newTrackerViewModel.changeCategory(to: title)

            self.tableView.reloadRows(
                at: [
                    IndexPath(
                        row: 0,
                        section: Section.settings.rawValue
                    )
                ],
                with: .none
            )
        }

        navigationController?.pushViewController(
            viewController,
            animated: true
        )
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

    @objc private func didChangeHabitName() {
        newTrackerViewModel.changeName(to: habitNameTextField.text ?? "")
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapAddButton() {

        guard let tracker = newTrackerViewModel.makeTracker(),
            let category = newTrackerViewModel.selectedCategory,
            let delegate
        else { return }

        do {
            if newTrackerViewModel.isEditing {
                try delegate.didUpdateTracker(
                    tracker,
                    categoryTitle: category
                )
            } else {
                try delegate.didCreateTracker(
                    tracker,
                    categoryTitle: category
                )
            }

            dismiss(animated: true)
        } catch {

            let errorMessage =
                newTrackerViewModel.isEditing
                ? String(localized: .trackerUpdateError)
                : String(localized: .trackerCreationSaveError)

            showErrorAlert(
                message: errorMessage
            )
        }
    }
    
    @objc
    private func didPressReturn() {
        habitNameTextField.resignFirstResponder()
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
            return UITableView.automaticDimension

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

            cell.backgroundColor = .ypBackground
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

            cell.backgroundColor = .ypBackground

            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )

            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.textLabel?.textColor = .ypBlack

            cell.detailTextLabel?.font = .systemFont(ofSize: 17)
            cell.detailTextLabel?.textColor = .ypGray

            switch indexPath.row {
            case 0:
                cell.textLabel?.text = String(localized: .categoryTitle)
                cell.detailTextLabel?.text =
                    newTrackerViewModel.selectedCategory

            case 1:
                guard showsSchedule else {
                    break
                }

                cell.textLabel?.text = String(localized: .scheduleTitle)

                cell.detailTextLabel?.text =
                    newTrackerViewModel.scheduleDescription

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

            cell.selectEmoji(newTrackerViewModel.selectedEmoji)

            cell.onEmojiSelected = { [weak self] emoji in
                self?.newTrackerViewModel.changeEmoji(to: emoji)
            }

            cell.onHeightChanged = { [weak self] in
                DispatchQueue.main.async {
                    guard let self else { return }

                    UIView.performWithoutAnimation {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
            }

            return cell

        case .color:
            let cell = CollectionTableViewCell(
                type: .color,
                reuseIdentifier: nil
            )

            cell.selectColor(newTrackerViewModel.selectedColor)

            cell.onColorSelected = { [weak self] color in
                self?.newTrackerViewModel.changeColor(to: color)
            }

            cell.onHeightChanged = { [weak self] in
                DispatchQueue.main.async {
                    guard let self else { return }

                    UIView.performWithoutAnimation {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
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
                openCategorySelection()

            case 1:

                guard showsSchedule else {
                    return
                }

                let viewController = ScheduleViewController(
                    selectedDays: newTrackerViewModel.selectedSchedule
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

        case .name:
            guard newTrackerViewModel.isEditing else { return nil }

            let label = UILabel()
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textColor = .ypBlack

            let components = DateComponents(
                day: newTrackerViewModel.completedDays
            )

            label.text = daysFormatter.string(from: components)

            let container = UIView()
            container.backgroundColor = .ypWhite

            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(
                    equalTo: container.topAnchor,
                    constant: 24
                ),
                label.bottomAnchor.constraint(
                    equalTo: container.bottomAnchor,
                    constant: -40
                ),
                label.centerXAnchor.constraint(
                    equalTo: container.centerXAnchor
                ),
            ])

            return container

        case .emoji, .color:
            let label = UILabel()

            label.text =
                tableSection == .emoji
                ? String(localized: .emojiTitle)
                : String(localized: .colorTitle)
            label.font = .systemFont(ofSize: 19, weight: .bold)
            label.textColor = .ypBlack

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

        case .settings:
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

        case .name:
            return newTrackerViewModel.isEditing
                ? collectionHeaderHeight + 70 : sectionSpacing

        case .emoji, .color:
            return collectionHeaderHeight

        case .settings:
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
        newTrackerViewModel.changeSchedule(to: schedule)

        tableView.reloadRows(
            at: [IndexPath(row: 1, section: 1)],
            with: .none
        )
    }
}
