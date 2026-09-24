//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 21.09.2026.
//

import CoreData
import Foundation

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: StoreDelegate?

    var records: [TrackerRecord] {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let records = try? objects.map({
                try record(from: $0)
            })
        else {
            return []
        }

        return records
    }

    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerRecordCoreData> = {

            let fetchRequest = TrackerRecordCoreData.fetchRequest()

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \TrackerRecordCoreData.date,
                    ascending: true
                )
            ]

            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            controller.delegate = self
            return controller
        }()

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        try fetchedResultsController.performFetch()
    }

    private func record(
        from recordCoreData: TrackerRecordCoreData
    ) throws -> TrackerRecord {

        guard let id = recordCoreData.id else {
            throw StoreError.invalidRecordID
        }

        guard let date = recordCoreData.date else {
            throw StoreError.invalidRecordDate
        }

        return TrackerRecord(
            id: id,
            date: date
        )
    }

    func addRecord(_ record: TrackerRecord) throws {
        let trackerRequest = TrackerCoreData.fetchRequest()

        trackerRequest.predicate = NSPredicate(
            format: "id == %@",
            record.id as NSUUID
        )

        guard
            let trackerCoreData =
                try context.fetch(trackerRequest).first
        else {
            throw StoreError.trackerNotFound
        }

        let recordCoreData =
            TrackerRecordCoreData(context: context)

        recordCoreData.id = record.id
        recordCoreData.date = record.date
        recordCoreData.tracker = trackerCoreData

        try context.save()
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        guard
            let recordCoreData = fetchedResultsController.fetchedObjects?
                .first(where: {
                    guard let date = $0.date else {
                        return false
                    }

                    return $0.id == record.id
                        && Calendar.current.isDate(
                            date,
                            inSameDayAs: record.date
                        )
                })
        else {
            return
        }

        context.delete(recordCoreData)
        try context.save()
    }
}

extension TrackerRecordStore:
    NSFetchedResultsControllerDelegate
{

    func controllerDidChangeContent(
        _ controller:
            NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.storeDidUpdate()
    }
}
