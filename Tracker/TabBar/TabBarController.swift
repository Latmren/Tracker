//
//  TabBarController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Properties

    private var didAttemptSetup = false

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didAttemptSetup else { return }
        didAttemptSetup = true

        setupTabs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

    }

    // MARK: - Setup

    private func setupUI() {

        tabBar.tintColor = UIColor(resource: .ypBlue)
        tabBar.unselectedItemTintColor = UIColor(resource: .ypGray)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .ypGray

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupTabs() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            showSetupError()
            return
        }

        let trackersListViewController: TrackersListViewController

        let statisticsViewController: StatisticsViewController

        do {
            let stores = try appDelegate.makeStores()

            let trackersListViewModel = TrackersListViewModel(
                trackerStore: stores.tracker,
                categoryStore: stores.category,
                recordStore: stores.record
            )

            let statisticsViewModel = StatisticsViewModel(
                recordStore: stores.record,
                categoryStore: stores.category
            )

            trackersListViewController = TrackersListViewController(
                viewModel: trackersListViewModel,
                categoryStore: stores.category
            )

            statisticsViewController = StatisticsViewController(
                viewModel: statisticsViewModel
            )

            trackersListViewController.onCompletionChanged = {
                [weak statisticsViewModel] in
                statisticsViewModel?.refresh()
            }

        } catch {
            showSetupError()
            return
        }

        let statisticsNavigationController = UINavigationController(
            rootViewController: statisticsViewController
        )

        statisticsViewController.tabBarItem = UITabBarItem(
            title: String(localized: .statisticsTitle),
            image: UIImage(resource: .statistics),
            selectedImage: nil
        )

        let trackersNavigationController = UINavigationController(
            rootViewController: trackersListViewController
        )

        trackersListViewController.tabBarItem = UITabBarItem(
            title: String(localized: .trackersTitle),
            image: UIImage(resource: .tracker),
            selectedImage: nil
        )

        self.viewControllers = [
            trackersNavigationController, statisticsNavigationController,
        ]
    }

    // MARK: - Error Handling

    private func showSetupError() {
        let alert = UIAlertController(
            title: String(localized: .genericErrorTitle),
            message: String(localized: .appSetupError),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: .retryButton),
                style: .default
            ) { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    [weak self] in
                    self?.setupTabs()
                }
            }
        )
        present(alert, animated: true)
    }

}
