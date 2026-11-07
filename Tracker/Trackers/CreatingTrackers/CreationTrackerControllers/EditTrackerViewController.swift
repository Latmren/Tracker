//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 05.11.2026.
//

import UIKit

final class EditTrackerViewController: NewTrackerViewController {

    init(
        tracker: Tracker,
        categoryTitle: String,
        categoryStore: TrackerCategoryStore,
        completedDays: Int
    ) {

        let viewModel = NewTrackerViewModel(
            tracker: tracker,
            categoryTitle: categoryTitle,
            completedDays: completedDays
        )

        super.init(
            title: String(localized: .editTrackerTitle),
            showSchedule: true,
            categoryStore: categoryStore,
            newTrackerViewModel: viewModel
        )
    }

}
