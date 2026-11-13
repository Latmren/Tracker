//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Dmitry Zherebyatnikov on 20.08.2026.
//

import SnapshotTesting
import XCTest

@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    private func makeMainScreen() throws -> TrackersListViewController {
        let appDelegate = try XCTUnwrap(
            UIApplication.shared.delegate as? AppDelegate
        )

        let trackersListViewController: TrackersListViewController

        let stores = try appDelegate.makeInMemoryStores()

        let trackersListViewModel = TrackersListViewModel(
            trackerStore: stores.tracker,
            categoryStore: stores.category,
            recordStore: stores.record
        )

        trackersListViewController = TrackersListViewController(
            viewModel: trackersListViewModel,
            categoryStore: stores.category
        )

        return trackersListViewController
    }

    func testLightViewController() throws {
        let screen = try makeMainScreen()
        screen.view.overrideUserInterfaceStyle = .light

        assertSnapshot(
            of: screen,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }

    func testDarkViewController() throws {
        let screen = try makeMainScreen()
        screen.view.overrideUserInterfaceStyle = .dark

        assertSnapshot(
            of: screen,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
