//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 21.09.2026.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let mapper = TrackerCoreDataMapper()
    weak var delegate: StoreDelegate?

    var categories: [TrackerCategory] {
        guard
            let objects = fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({
                try category(from: $0)
            })
        else {
            return []
        }

        return categories
    }

    private lazy var fetchedResultsController:
        NSFetchedResultsController<TrackerCategoryCoreData> = {
            let fetchRequest = TrackerCategoryCoreData.fetchRequest()

            fetchRequest.sortDescriptors = [
                NSSortDescriptor(
                    keyPath: \TrackerCategoryCoreData.title,
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

    private func category(
        from categoryCoreData: TrackerCategoryCoreData
    ) throws -> TrackerCategory {

        guard let title = categoryCoreData.title else {
            throw StoreError.invalidCategoryTitle
        }

        let trackerObjects =
            categoryCoreData.tracker?.allObjects as? [TrackerCoreData] ?? []

        let trackers = try trackerObjects.map {
            try mapper.tracker(from: $0)
        }

        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller:
            NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.storeDidUpdate()
    }
}
