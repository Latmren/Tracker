//
//  NewTrackerViewModel.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 03.11.2026.
//

import UIKit

final class NewTrackerViewModel {

    //MARK: - Properties

    private let editingTrackerID: UUID?

    private(set) var selectedEmoji: String?
    private(set) var selectedColor: UIColor?
    private(set) var selectedCategory: String? = nil
    private(set) var selectedSchedule: Set<WeekDay> = []

    private(set) var trackerName = ""
    private(set) var completedDays = 0

    var onFormChanged: (() -> Void)?

    var isNameOverLimit: Bool {
        let characterCount =
            trackerName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .count

        return characterCount > maxNameLength
    }

    var canCreate: Bool {
        let isNameValid =
            !trackerName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
            && !isNameOverLimit

        let isScheduleValid = !selectedSchedule.isEmpty

        let isCategorySelected = selectedCategory != nil

        let isEmojiSelected = selectedEmoji != nil

        let isColorSelected = selectedColor != nil

        return
            isNameValid && isScheduleValid && isCategorySelected
            && isEmojiSelected && isColorSelected
    }

    var scheduleDescription: String {

        if selectedSchedule.count == WeekDay.allCases.count {
            return String(
                localized: .everyDayTitle
            )
        } else {

            let symbols = shortWeekdaySymbols

            guard symbols.count == 7 else {
                return ""
            }

            return WeekDay.allCases
                .enumerated()
                .filter { selectedSchedule.contains($0.element) }
                .map {
                    symbols[$0.offset].localizedCapitalized
                }
                .joined(separator: ", ")
        }
    }

    private let weekdayFormatter = DateFormatter()

    private var shortWeekdaySymbols: [String] {
        guard
            let symbols = weekdayFormatter.shortWeekdaySymbols,
            symbols.count == 7
        else {
            return []
        }

        return Array(symbols[1...]) + [symbols[0]]
    }

    var isEditing: Bool {
        editingTrackerID != nil
    }

    //MARK: - Initialization

    init(initialSchedule: Set<WeekDay>) {
        self.editingTrackerID = nil
        self.selectedSchedule = initialSchedule
    }

    // Editing an existing tracker
    
    init(tracker: Tracker, categoryTitle: String, completedDays: Int) {
        self.editingTrackerID = tracker.id
        self.trackerName = tracker.title
        self.selectedEmoji = tracker.emoji
        self.selectedColor = tracker.color
        self.selectedCategory = categoryTitle
        self.selectedSchedule = tracker.schedule
        self.completedDays = completedDays
    }

    //MARK: - Private functions

    func changeName(to name: String) {
        trackerName = name
        onFormChanged?()
    }

    func changeCategory(to category: String) {
        selectedCategory = category
        onFormChanged?()
    }

    func changeSchedule(to schedule: Set<WeekDay>) {
        selectedSchedule = schedule
        onFormChanged?()
    }

    func changeEmoji(to emoji: String) {
        selectedEmoji = emoji
        onFormChanged?()
    }

    func changeColor(to color: UIColor) {
        selectedColor = color
        onFormChanged?()
    }

    func makeTracker() -> Tracker? {
        guard canCreate, let selectedColor, let selectedEmoji else {
            return nil
        }
        return Tracker(
            id: editingTrackerID ?? UUID(),
            title: trackerName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
    }
}
