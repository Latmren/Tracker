//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

final class TrackersListViewController: UIViewController {

    // MARK: - Properties
    private let analyticsService = AnalyticsService()

    private let trackersListViewModel: TrackersListViewModel

    private let categoryStore: TrackerCategoryStore

    var onCompletionChanged: (() -> Void)?

    private enum SystemImageName: String {
        case plus
    }

    // MARK: - UI Elements

    private let searchController = UISearchController(
        searchResultsController: nil
    )

    private let emptyStateView = EmptyStateView(
        image: UIImage(resource: .emptyTrackers),
        text: String(localized: .trackersEmptyMessage)
    )

    private let filtersButton: UIButton = {
        let button = UIButton()

        button.setTitle(String(localized: .filterTitle), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )
        button.layer.cornerRadius = 16
        button.overrideUserInterfaceStyle = .light
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()

        picker.translatesAutoresizingMaskIntoConstraints = false

        return picker
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
        )
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    // MARK: - Initialization

    init(viewModel: TrackersListViewModel, categoryStore: TrackerCategoryStore)
    {
        self.trackersListViewModel = viewModel
        self.categoryStore = categoryStore

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        datePicker.maximumDate = Date()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()

        bindViewModel()
        trackersListViewModel.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analyticsService.report(event: "open", params: ["screen": "Main"])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        analyticsService.report(event: "close", params: ["screen": "Main"])
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .ypWhite

        setupCollectionView()
        setupEmptyState()
        setupFilterButton()

    }

    private func setupCollectionView() {
        view.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell
                .reuseIdentifier
        )

        collectionView.contentInset.bottom = 50

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
        ])

        collectionView.register(
            TrackerCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionHeaderView.reuseIdentifier
        )
    }

    private func setupFilterButton() {
        view.addSubview(filtersButton)

        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            filtersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        filtersButton.addTarget(
            self,
            action: #selector(didTapAddFilters),
            for: .touchUpInside
        )
    }

    private func updateFilterButtonAppearance(isActive active: Bool) {
        switch active {
        case true:
            filtersButton.backgroundColor = .ypGreen
        case false:
            filtersButton.backgroundColor = .ypBlue
        }
    }

    private func setupNavigationBar() {
        navigationItem.title = String(localized: .trackersTitle)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.searchBar.placeholder = String(
            localized: .searchPlaceholder
        )
        searchController.obscuresBackgroundDuringPresentation = false

        searchController.searchResultsUpdater = self

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .bold
        )

        let addImage = UIImage(
            systemName: SystemImageName.plus.rawValue,
            withConfiguration: configuration
        )

        let addButton = UIBarButtonItem(
            image: addImage,
            style: .plain,
            target: self,
            action: #selector(didTapAdd)
        )

        addButton.tintColor = .ypBlack

        navigationItem.leftBarButtonItem = addButton

        let datePickerItem = UIBarButtonItem(
            customView: datePicker
        )

        navigationItem.rightBarButtonItem = datePickerItem

        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )

        if #available(iOS 26.0, *) {
            datePickerItem.hidesSharedBackground = true
            addButton.hidesSharedBackground = true
        }

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

    // MARK: - Private Methods

    private func bindViewModel() {
        trackersListViewModel.onTrackersListChanges = { [weak self] in
            guard let self else { return }

            datePicker.date = trackersListViewModel.selectedDate
            collectionView.reloadData()
            updateEmptyState()
        }
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

    private func deletionConfirmationAlert(of tracker: Tracker) {
        let alert = UIAlertController(
            title: String(localized: .deleteTrackerConfirmation),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: .deleteTrackerButton),
                style: .destructive
            ) { [weak self] _ in

                guard let self else { return }

                do {
                    try self.trackersListViewModel.deleteTracker(tracker)
                    self.onCompletionChanged?()
                } catch {
                    self.showErrorAlert(
                        message: String(localized: .trackerDeletionError)
                    )
                }
            }
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: .cancelButton),
                style: .cancel
            )
        )

        present(alert, animated: true)
    }

    private func openTrackerEditor(
        for tracker: Tracker,
        categoryTitle: String
    ) {

        let editTrackerViewController = EditTrackerViewController(
            tracker: tracker,
            categoryTitle: categoryTitle,
            categoryStore: categoryStore,
            completedDays: trackersListViewModel.completedDays(for: tracker)
        )

        editTrackerViewController.delegate = self

        let navigationController = UINavigationController(
            rootViewController: editTrackerViewController
        )

        present(navigationController, animated: true)
    }

    private func updateEmptyState() {
        let isEmpty = trackersListViewModel.visibleCategories.isEmpty
        filtersButton.isHidden =
            trackersListViewModel.selectedFilter == .all && isEmpty

        switch trackersListViewModel.selectedFilter {
        case .all:
            if trackersListViewModel.searchText.isEmpty {
                emptyStateView.change(
                    to: String(localized: .trackersEmptyMessage),
                    with: .emptyTrackers
                )
            } else {
                emptyStateView.change(
                    to: String(localized: .nothingFoundTitle),
                    with: .emptySearch
                )
            }
        case .completed, .incomplete:
            emptyStateView.change(
                to: String(localized: .nothingFoundTitle),
                with: .emptySearch
            )
        }

        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    // MARK: - Actions

    @objc
    private func didTapAdd() {

        let addTrackerViewController = AddTrackerViewController(
            categoryStore: categoryStore
        )

        addTrackerViewController.delegate = self

        let navigationController = UINavigationController(
            rootViewController: addTrackerViewController
        )

        present(navigationController, animated: true)

        analyticsService.report(
            event: "click",
            params: [
                "screen": "Main",
                "item": "add_track",
            ]
        )
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        trackersListViewModel.changeDate(to: sender.date)
    }

    @objc
    private func didTapAddFilters() {
        let filterViewController = FilterViewController(
            selectedFilter: trackersListViewModel.selectedFilter
        )

        filterViewController.delegate = self

        let navigationController = UINavigationController(
            rootViewController: filterViewController
        )

        present(navigationController, animated: true)

        analyticsService.report(
            event: "click",
            params: [
                "screen": "Main",
                "item": "filter",
            ]
        )
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersListViewController: UICollectionViewDataSource {

    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        trackersListViewModel.visibleCategories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        trackersListViewModel.visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let trackers = trackersListViewModel.visibleCategories[
            indexPath.section
        ].trackers

        let tracker = trackers[indexPath.item]

        let completedDays = trackersListViewModel.completedDays(for: tracker)

        let isCompleted = trackersListViewModel.isCompleted(
            tracker,
            on: trackersListViewModel.selectedDate
        )

        cell.configure(
            with: tracker,
            completedDays: completedDays,
            isCompleted: isCompleted
        )

        cell.delegate = self

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        guard
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCollectionHeaderView
                    .reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionHeaderView
        else {
            return UICollectionReusableView()
        }

        header.configure(
            with: trackersListViewModel.visibleCategories[indexPath.section]
                .title
        )

        return header
    }
}

extension TrackersListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let horizontalInset: CGFloat = 16 * 2
        let spacing: CGFloat = 9

        let width =
            (collectionView.bounds.width
                - horizontalInset
                - spacing) / 2

        return CGSize(
            width: width,
            height: 148
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {

        let trackers = trackersListViewModel.visibleCategories[section].trackers

        guard !trackers.isEmpty else {
            return .zero
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: 46
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let category = trackersListViewModel.visibleCategories[
            indexPath.section
        ]
        let trackers = category.trackers
        let tracker = trackers[indexPath.item]

        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            return UIMenu(children: [
                UIAction(
                    title: String(localized: .editTrackerButton),
                    //image: UIImage(systemName: "pencil")  // Нет такого исполнения в Figma, хочу потом оставить в проекте
                ) { _ in
                    self?.openTrackerEditor(
                        for: tracker,
                        categoryTitle: category.title
                    )

                    self?.analyticsService.report(
                        event: "click",
                        params: [
                            "screen": "Main",
                            "item": "edit",
                        ]
                    )
                },
                UIAction(
                    title: String(localized: .deleteTrackerButton),
                    //image: UIImage(systemName: "trash"),  // Нет такого исполнения в Figma, хочу потом оставить в проекте
                    attributes: .destructive
                ) {
                    [weak self] _ in
                    self?.deletionConfirmationAlert(of: tracker)

                    self?.analyticsService.report(
                        event: "click",
                        params: [
                            "screen": "Main",
                            "item": "delete",
                        ]
                    )
                },
            ])
        })
    }
}

extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        analyticsService.report(
            event: "click",
            params: [
                "screen": "Main",
                "item": "track",
            ]
        )

        let trackers = trackersListViewModel.visibleCategories[
            indexPath.section
        ].trackers
        let tracker = trackers[indexPath.item]

        do {
            try trackersListViewModel.toggleCompletion(
                for: tracker,
                on: trackersListViewModel.selectedDate
            )

            onCompletionChanged?()
        } catch {
            showErrorAlert(
                message: String(localized: .trackerCompletionSaveError)
            )
        }

    }

}

extension TrackersListViewController: TrackerFormDelegate {
    func didUpdateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws {
        try trackersListViewModel.updateTracker(
            tracker,
            categoryTitle: categoryTitle
        )
    }

    func didCreateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws {

        try trackersListViewModel.createTracker(
            tracker,
            categoryTitle: categoryTitle
        )

    }
}

extension TrackersListViewController: FilterViewControllerDelegate {
    func filterViewController(
        _ viewController: FilterViewController,
        didSelect filter: FilterNames
    ) {
        switch filter {
        case .all:
            trackersListViewModel.changeFilter(to: .all)
            updateFilterButtonAppearance(isActive: false)
        case .allToday:
            trackersListViewModel.showTrackersForToday()
            updateFilterButtonAppearance(isActive: false)
        case .completed:
            trackersListViewModel.changeFilter(to: .completed)
            updateFilterButtonAppearance(isActive: true)
        case .incomplete:
            trackersListViewModel.changeFilter(to: .incomplete)
            updateFilterButtonAppearance(isActive: true)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        trackersListViewModel.changeSearch(
            to: searchController.searchBar.text ?? ""
        )
    }
}
