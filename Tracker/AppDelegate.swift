//
//  AppDelegate.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 20.08.2026.
//

import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        DaysValueTransformer.register()
        
        ValueTransformer.setValueTransformer(
            UIColorValueTransformer(),
            forName: NSValueTransformerName("UIColorValueTransformer")
        )
        
        AnalyticsService.activate()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    // MARK: - Core Data stack

    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var testPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load test store: \(error)")
            }
        }

        return container
    }()

    func makeStores() throws -> (
        tracker: TrackerStore,
        category: TrackerCategoryStore,
        record: TrackerRecordStore
    ) {
        let context = persistentContainer.viewContext

        return (
            try TrackerStore(context: context),
            try TrackerCategoryStore(context: context),
            try TrackerRecordStore(context: context)
        )
    }
    
    func makeInMemoryStores() throws -> (
        tracker: TrackerStore,
        category: TrackerCategoryStore,
        record: TrackerRecordStore
    ) {
        let context = testPersistentContainer.viewContext

        return (
            try TrackerStore(context: context),
            try TrackerCategoryStore(context: context),
            try TrackerRecordStore(context: context)
        )
    }

    func makeRecordStore() throws -> TrackerRecordStore {
        try TrackerRecordStore(
            context: persistentContainer.viewContext
        )
    }

    func makeCategoryStore() throws -> TrackerCategoryStore {
        try TrackerCategoryStore(
            context: persistentContainer.viewContext
        )
    }

    func makeTrackerStore() throws -> TrackerStore {
        try TrackerStore(
            context: persistentContainer.viewContext
        )
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Не удалось сохранить Core Data: \(error)")
            }
        }
    }

}
