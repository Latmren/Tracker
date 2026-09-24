//
//  TrackerCoreDataMapper.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 24.09.2026.
//

import UIKit

final class TrackerCoreDataMapper {


    func tracker(from trackerCoreData: TrackerCoreData) throws
        -> Tracker
    {
        guard let id = trackerCoreData.id else {
            throw StoreError.invalidTrackerID
        }

        guard let title = trackerCoreData.title else {
            throw StoreError.invalidTrackerTitle
        }

        guard let color = trackerCoreData.color as? UIColor else {
            throw StoreError.invalidTrackerColor
        }

        guard let emoji = trackerCoreData.emoji else {
            throw StoreError.invalidTrackerEmoji
        }

        guard let schedule = trackerCoreData.schedule as? Set<WeekDay>
        else {
            throw StoreError.invalidTrackerSchedule
        }

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}
