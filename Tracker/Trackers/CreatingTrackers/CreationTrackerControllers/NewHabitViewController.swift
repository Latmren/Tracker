//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 14.09.2026.
//

import UIKit

final class NewHabitViewController: NewTrackerViewController {

    init(categoryStore: TrackerCategoryStore) {
        super.init(
            title: "Новая привычка",
            showSchedule: true,
            initialSchedule: [],
            categoryStore: categoryStore
        )
    }

}
