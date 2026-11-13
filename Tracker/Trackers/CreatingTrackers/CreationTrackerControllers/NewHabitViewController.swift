//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 14.09.2026.
//

import UIKit

final class NewHabitViewController: NewTrackerViewController {

    init(categoryStore: TrackerCategoryStore) {

        let viewModel = NewTrackerViewModel(
            initialSchedule: []
        )

        super.init(
            title: String(localized: .newHabitTitle),
            showSchedule: true,
            categoryStore: categoryStore,
            newTrackerViewModel: viewModel
        )
    }

}
