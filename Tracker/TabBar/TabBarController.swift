//
//  TabBarController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.09.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = UIColor(resource: .ypBlue)
        tabBar.unselectedItemTintColor = UIColor(resource: .ypGray)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .ypGray
        

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        let trackersListViewController = TrackersListViewController()

        let trackersNavigationController = UINavigationController(
            rootViewController: trackersListViewController
        )

        trackersListViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tracker),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(
            rootViewController: statisticsViewController
        )

        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statistics),
            selectedImage: nil
        )

        self.viewControllers = [
            trackersNavigationController, statisticsNavigationController,
        ]
    }

}
