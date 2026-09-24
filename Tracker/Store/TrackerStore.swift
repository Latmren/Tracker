//
//  TrackerStore.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 21.09.2026.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    weak var delegate: StoreDelegate?


    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerCoreData> = {
            let fetchRequest = TrackerCoreData.fetchRequest()

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \TrackerCoreData.title,
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

    private func update(
        _ trackerCoreData: TrackerCoreData,
        with tracker: Tracker
    ) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
    }

    func addNewTracker(
        _ tracker: Tracker,
        categoryTitle: String
    ) throws {

        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            categoryTitle
        )
        categoryRequest.fetchLimit = 1

        let categoryCoreData: TrackerCategoryCoreData

        if let existingCategory = try context.fetch(categoryRequest).first {
            categoryCoreData = existingCategory
        } else {
            categoryCoreData = TrackerCategoryCoreData(context: context)
            categoryCoreData.title = categoryTitle
        }

        let trackerCoreData = TrackerCoreData(context: context)

        update(trackerCoreData, with: tracker)

        trackerCoreData.trackerCategory = categoryCoreData

        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.storeDidUpdate()
    }
}
