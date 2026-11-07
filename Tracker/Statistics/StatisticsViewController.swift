//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

private enum Section: Int, CaseIterable {
    case bestStreak
    case idealDays
    case trackerRecordCount
    case average
}

final class StatisticsViewController: UIViewController {

    // MARK: - Properties

    private let statisticViewModel: StatisticsViewModel

    private let emptyStateView = EmptyStateView(
        image: UIImage(resource: .emptyStatistics),
        text: String(localized: .statisticsEmptyMessage)
    )

    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )

        tableView.backgroundColor = .ypWhite

        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Initialization

    init(viewModel: StatisticsViewModel) {
        self.statisticViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()

        setupUI()
        setupNavigationBar()
        setupEmptyState()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticViewModel.refresh()
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = .ypWhite

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderTopPadding = 0

        NSLayoutConstraint.activate([

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            tableView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: 400
            ),
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = String(localized: .statisticsTitle)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])

        updateEmptyState()
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        statisticViewModel.onStatisticsChanged = { [weak self] in
            self?.updateEmptyState()
            self?.tableView.reloadData()
        }
    }

    private func updateEmptyState() {
        let isEmpty = !statisticViewModel.hasStatisticsData

        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableView DataSource & Delegate

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        Section.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        1
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 90
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
        case .bestStreak:

            let cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: nil
            )

            cell.textLabel?.text = "\(statisticViewModel.bestStreak)"
            cell.detailTextLabel?.text = String(
                localized: .statisticsBestPeriod
            )
            cell.selectionStyle = .none
            cell.backgroundView = GradientBorderView()
            cell.backgroundColor = .clear

            return cell

        case .idealDays:

            let cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: nil
            )

            cell.textLabel?.text = "\(statisticViewModel.idealDaysCount)"
            cell.detailTextLabel?.text = String(localized: .statisticsIdealDays)
            cell.selectionStyle = .none
            cell.backgroundView = GradientBorderView()
            cell.backgroundColor = .clear

            return cell

        case .trackerRecordCount:

            let cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: nil
            )

            cell.textLabel?.text = "\(statisticViewModel.completedCount)"
            cell.detailTextLabel?.text = String(
                localized: .statisticsTrackersCompleted
            )
            cell.selectionStyle = .none
            cell.backgroundView = GradientBorderView()
            cell.backgroundColor = .clear

            return cell

        case .average:

            let cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: nil
            )

            cell.textLabel?.text = statisticViewModel.averageCount.formatted(
                .number.precision(.fractionLength(0...2))
            )
            cell.detailTextLabel?.text = String(
                localized: .statisticsAverageValue
            )
            cell.selectionStyle = .none
            cell.backgroundView = GradientBorderView()
            cell.backgroundColor = .clear

            return cell
        }

    }
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        section == 0 ? .leastNormalMagnitude : 12
    }
}
