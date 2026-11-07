//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 28.10.2026.
//

import Foundation

final class StatisticsViewModel {

    // MARK: - Properties

    private let recordStore: TrackerRecordStore
    private let categoryStore: TrackerCategoryStore
    private let calendar = Calendar.current

    private(set) var completedCount = 0
    private(set) var bestStreak = 0
    private(set) var averageCount = 0.0
    private(set) var hasStatisticsData = false

    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case idealDays
    }

    private var idealDays: Set<Date> = []

    var idealDaysCount: Int {
        idealDays.count
    }

    var onStatisticsChanged: (() -> Void)?

    // MARK: - Initialization

    init(recordStore: TrackerRecordStore, categoryStore: TrackerCategoryStore) {
        self.recordStore = recordStore
        self.categoryStore = categoryStore

        let savedDates =
            storage.array(forKey: Keys.idealDays.rawValue) as? [Date] ?? []

        idealDays = Set(savedDates)

    }

    // MARK: - Public Methods

    func refresh() {
        hasStatisticsData =
            categoryStore.categories.contains {
                !$0.trackers.isEmpty
            } || !recordStore.records.isEmpty

        let records = recordStore.records
        let counts = completedCountsByDay(from: records)

        completedCount = records.count

        calculateIdealDays(from: counts)

        averageCount = calculateAverage(
            from: counts
        )
        bestStreak = calculateBestStreak(
            from: counts
        )
        onStatisticsChanged?()

    }

    // MARK: - Private Calculations

    private func completedCountsByDay(
        from records: [TrackerRecord]
    ) -> [Date: Int] {

        let counts = records.reduce(into: [Date: Int]()) { result, record in
            let day = calendar.startOfDay(for: record.date)
            result[day, default: 0] += 1
        }
        return counts
    }

    private func scheduledCount(for date: Date) -> Int {
        guard let weekday = WeekDay(date: date, calendar: calendar) else {
            return 0
        }
        var count = 0
        for category in categoryStore.categories {
            count += category.trackers.reduce(into: Int()) { result, tracker in
                if tracker.schedule.contains(weekday) {
                    result += 1
                }
            }
        }
        return count
    }

    private func calculateIdealDays(
        from counts: [Date: Int]
    ) {
        var hasNewIdealDays = false

        for (date, completed) in counts {
            let scheduledCount = scheduledCount(for: date)
            if completed == scheduledCount && scheduledCount > 0 {
                if idealDays.insert(date).inserted {
                    hasNewIdealDays = true
                }
            }
        }
        if hasNewIdealDays {
            storage.set(
                Array(idealDays),
                forKey: Keys.idealDays.rawValue
            )
        }
    }

    private func calculateAverage(
        from counts: [Date: Int]
    ) -> Double {
        guard let firstRecordDay = counts.keys.min() else { return 0 }

        let totalCompletions = counts.values.reduce(0, +)

        let totalDays =
            calendar.dateComponents(
                [.day],
                from: firstRecordDay,
                to: calendar.startOfDay(for: .now)
            ).day

        guard let totalDays else { return 0 }

        return Double(totalCompletions) / Double(totalDays + 1)
    }

    private func calculateBestStreak(
        from counts: [Date: Int]
    ) -> Int {
        let sortedDays = counts.keys.sorted()

        var bestStreak = 0
        var currentStreak = 0

        guard let firstDay = sortedDays.first else { return 0 }
        var previousDay = firstDay

        for day in sortedDays {
            if let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: previousDay
            ), calendar.isDate(day, inSameDayAs: nextDay) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }

            bestStreak = max(bestStreak, currentStreak)

            previousDay = day
        }

        return bestStreak
    }
}
