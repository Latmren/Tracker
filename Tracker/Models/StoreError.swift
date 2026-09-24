//
//  StoreError.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 24.09.2026.
//

enum StoreError: Error {
    case appDelegateUnavailable

    case invalidTrackerID
    case invalidTrackerTitle
    case invalidTrackerColor
    case invalidTrackerEmoji
    case invalidTrackerSchedule
    
    case invalidCategoryTitle
    
    case invalidRecordID
    case invalidRecordDate
    case trackerNotFound
}
