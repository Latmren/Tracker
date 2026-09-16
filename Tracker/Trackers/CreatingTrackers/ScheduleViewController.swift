//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 15.09.2026.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(
        _ viewController: ScheduleViewController,
        didSelect schedule: Set<WeekDay>
    )
}

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?

    private var selectedDays: Set<WeekDay>

    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypWhite
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlackDay
        button.titleLabel?.font = .systemFont(
            ofSize: 16,
            weight: .medium
        )
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(selectedDays: Set<WeekDay>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Расписание"
        view.backgroundColor = .ypWhite

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(doneButton)

        doneButton.addTarget(
            self,
            action: #selector(didTapDone),
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
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
                equalTo: doneButton.topAnchor,
                constant: -39
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

    @objc
    private func didTapDone() {
        delegate?.scheduleViewController(
            self,
            didSelect: selectedDays
        )

        navigationController?.popViewController(animated: true)
    }

    @objc
    private func switchChanged(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]

        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }

    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    private var weekdaySymbols: [String] {
        guard let symbols = weekdayFormatter.weekdaySymbols,
            symbols.count == 7
        else {
            return []
        }

        return Array(symbols[1...]) + [symbols[0]]
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        WeekDay.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let day = WeekDay.allCases[indexPath.row]

        let cell = UITableViewCell(
            style: .default,
            reuseIdentifier: nil
        )

        cell.textLabel?.text = weekdaySymbols[indexPath.row].capitalized

        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none

        let switchView = UISwitch()
        switchView.isOn = selectedDays.contains(day)
        switchView.tag = indexPath.row

        switchView.addTarget(
            self,
            action: #selector(switchChanged(_:)),
            for: .valueChanged
        )

        cell.accessoryView = switchView

        return cell
    }
}
