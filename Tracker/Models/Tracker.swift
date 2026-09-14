//
//  Tracker.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

public struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>
}

enum WeekDay: Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    static let orderedDays: [WeekDay] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday,
    ]

    init?(date: Date, calendar: Calendar = .current) {
        switch calendar.component(.weekday, from: date) {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
}
