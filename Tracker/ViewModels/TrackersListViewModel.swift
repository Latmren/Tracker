//
//  TrackersListViewModel.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.11.2026.
//

import Foundation

enum FilterState {
    case all
    case completed
    case incomplete
}

final class TrackersListViewModel {

    // MARK: - Properties

    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    private let calendar = Calendar.current

    private(set) var categories: [TrackerCategory] = []
    private(set) var visibleCategories: [TrackerCategory] = []

    private(set) var completedTrackers: [TrackerRecord] = []

    private(set) var selectedDate = Date()
    private(set) var searchText = ""
    private(set) var selectedFilter = FilterState.all

    var onTrackersListChanges: (() -> Void)?

    // MARK: - Initialization

    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore

        self.trackerStore.delegate = self
        self.categoryStore.delegate = self
        self.recordStore.delegate = self
    }

    // MARK: - Public Methods

    func refresh() {
        categories = categoryStore.categories
        completedTrackers = recordStore.records

        updateVisibleCategories(for: selectedDate, search: searchText)
        onTrackersListChanges?()
    }

    func changeDate(to date: Date) {
        selectedDate = date
        updateVisibleCategories(for: selectedDate, search: searchText)
        onTrackersListChanges?()
    }

    func changeSearch(to text: String) {
        searchText = text
        updateVisibleCategories(for: selectedDate, search: searchText)
        onTrackersListChanges?()
    }

    func changeFilter(to filter: FilterState) {
        selectedFilter = filter
        updateVisibleCategories(for: selectedDate, search: searchText)
        onTrackersListChanges?()
    }

    func showTrackersForToday() {
        selectedDate = Date()
        selectedFilter = .all
        updateVisibleCategories(for: selectedDate, search: searchText)
        onTrackersListChanges?()
    }

    func completedDays(for tracker: Tracker) -> Int {
        return completedTrackers.filter {
            $0.id == tracker.id
        }.count
    }

    func isCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains {
            $0.id == tracker.id
                && calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    func toggleCompletion(
        for tracker: Tracker,
        on date: Date
    ) throws {
        let isCompleted = isCompleted(tracker, on: date)

        let record = TrackerRecord(
            id: tracker.id,
            date: date
        )

        if isCompleted {
            try recordStore.deleteRecord(record)
        } else {
            try recordStore.addRecord(record)
        }
    }

    func createTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws {
        try trackerStore.addNewTracker(tracker, categoryTitle: categoryTitle)
    }

    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(with: tracker.id)
    }

    func updateTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws {
        try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
    }

    // MARK: - Filtering

    private func updateVisibleCategories(for date: Date, search: String) {
        guard let weekday = WeekDay(date: date, calendar: calendar) else {
            visibleCategories = []
            return
        }

        let query =
            search
            .trimmingCharacters(in: .whitespacesAndNewlines)

        visibleCategories = categories.compactMap { category in

            let trackers = category.trackers.filter { tracker in

                let matchesSchedule = tracker.schedule.contains(weekday)

                let matchesSearch =
                    query.isEmpty
                    || tracker.title.localizedStandardContains(query)

                guard matchesSchedule && matchesSearch else {
                    return false
                }

                switch selectedFilter {
                case .all:
                    return true

                case .completed:
                    return self.isCompleted(tracker, on: date)

                case .incomplete:
                    return !self.isCompleted(tracker, on: date)
                }

            }

            guard !trackers.isEmpty else { return nil }

            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
    }

}

// MARK: - StoreDelegate

extension TrackersListViewModel: StoreDelegate {
    func storeDidUpdate() {
        refresh()
    }
}
