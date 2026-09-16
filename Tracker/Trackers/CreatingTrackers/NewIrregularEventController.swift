//
//  NewIrregularEventController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 15.09.2026.
//

import UIKit

final class NewIrregularEventViewController: NewTrackerViewController {

    init() {
        super.init(
            title: "Новое нерегулярное событие",
            showSchedule: false,
            initialSchedule: Set(WeekDay.allCases)
        )
    }

}
