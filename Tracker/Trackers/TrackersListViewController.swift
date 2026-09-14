//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

final class TrackersListViewController: UIViewController {

    // MARK: - Properties

    private var categories: [TrackerCategory] = []

    private var completedTrackers: [TrackerRecord] = []

    // MARK: - UI Elements

    private let searchController = UISearchController(
        searchResultsController: nil
    )

    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyTrackers)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()

        picker.layer.cornerRadius = 8

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

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        datePicker.maximumDate = Date()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()

    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .ypWhite

        setupCollectionView()
        setupEmptyState()

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

    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )

        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupEmptyState() {
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyStateImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

            emptyStateLabel.topAnchor.constraint(
                equalTo: emptyStateImageView.bottomAnchor,
                constant: 8
            ),
            emptyStateLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
        ])

        updateEmptyState()
    }

    // MARK: - Private Methods

    private func updateEmptyState() {
        let isEmpty = categories.indices.allSatisfy {
            trackersForSelectedDate(in: $0).isEmpty
        }

        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func trackersForSelectedDate(in section: Int) -> [Tracker] {
        guard let weekday = WeekDay(date: datePicker.date) else { return [] }

        return categories[section].trackers.filter {
            $0.schedule.contains(weekday)
        }
    }

    // MARK: - Actions

    @objc
    private func didTapAdd() {
        let addTrackerViewController = AddTrackerViewController()
        
        addTrackerViewController.delegate = self

        
        let navigationController = UINavigationController(
            rootViewController: addTrackerViewController
        )
        
        present(navigationController, animated: true)
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {

        collectionView.reloadData()
        updateEmptyState()
    }

}

// MARK: - UICollectionViewDataSource

extension TrackersListViewController: UICollectionViewDataSource {

    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        trackersForSelectedDate(in: section).count
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

        let trackers = trackersForSelectedDate(
            in: indexPath.section
        )

        let tracker = trackers[indexPath.item]

        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count

        let isCompleted = completedTrackers.contains {
            $0.id == tracker.id
                && Calendar.current.isDate(
                    $0.date,
                    inSameDayAs: datePicker.date
                )
        }

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
            with: categories[indexPath.section].title
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

        let trackers = trackersForSelectedDate(in: section)

        guard !trackers.isEmpty else {
            return .zero
        }

        return CGSize(
            width: collectionView.bounds.width,
            height: 46
        )
    }
}

extension TrackersListViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let trackers = trackersForSelectedDate(in: indexPath.section)
        let tracker = trackers[indexPath.item]

        let selectedDate = datePicker.date

        let isCompleted = completedTrackers.contains {
            $0.id == tracker.id
                && Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }

        if isCompleted {
            completedTrackers = completedTrackers.filter {
                !($0.id == tracker.id
                    && Calendar.current.isDate(
                        $0.date,
                        inSameDayAs: selectedDate
                    ))
            }
        } else {
            let newRecord = TrackerRecord(
                id: tracker.id,
                date: selectedDate
            )
            completedTrackers = completedTrackers + [newRecord]
        }

        collectionView.reloadItems(at: [indexPath])
    }

}

extension TrackersListViewController: TrackerCreationDelegate {

    func didCreateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) {
        if let categoryIndex = categories.firstIndex(
            where: { $0.title == categoryTitle }
        ) {
            let category = categories[categoryIndex]

            categories[categoryIndex] = TrackerCategory(
                title: category.title,
                trackers: category.trackers + [tracker]
            )
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )

            categories = categories + [newCategory]
        }

        collectionView.reloadData()
        updateEmptyState()
    }
}
