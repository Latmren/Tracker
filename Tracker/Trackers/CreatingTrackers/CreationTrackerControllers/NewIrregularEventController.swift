//
//  NewIrregularEventController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 15.09.2026.
//

import UIKit

final class NewIrregularEventViewController: NewTrackerViewController {

    init(categoryStore: TrackerCategoryStore) {
        
        let viewModel = NewTrackerViewModel(
            initialSchedule: Set(WeekDay.allCases)
        )
        
        super.init(
            title: String(localized: .newIrregularEventTitle),
            showSchedule: false,
            categoryStore: categoryStore,
            newTrackerViewModel: viewModel
        )
    }

}
