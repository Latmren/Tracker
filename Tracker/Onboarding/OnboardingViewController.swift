//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 29.09.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {

    // MARK: - Properties

    private lazy var onboardPages: [OnboardPageViewController] = [
        OnboardPageViewController(
            backgroundImage: .background1,
            titleText: String(localized: .onboardingFirstTitle)
        ),
        OnboardPageViewController(
            backgroundImage: .background2,
            titleText: String(localized: .onboardingSecondTitle)
        ),
    ]

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = onboardPages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            String(localized: .onboardingContinueButton),
            for: .normal
        )
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(continueButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = onboardPages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }

        view.addSubview(pageControl)
        view.addSubview(continueButton)

        continueButton.overrideUserInterfaceStyle = .light

        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            continueButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),
            continueButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            continueButton.heightAnchor.constraint(equalToConstant: 60),

            pageControl.bottomAnchor.constraint(
                equalTo: continueButton.topAnchor,
                constant: -24
            ),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Actions

    @objc
    private func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        let tabBarController = TabBarController()

        guard let windowScene = view.window?.windowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }

        sceneDelegate.window?.rootViewController = tabBarController
    }

}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        //возвращаем предыдущий (относительно переданного viewController) дочерний контроллер
        guard
            let page = viewController as? OnboardPageViewController,
            let viewControllerIndex = onboardPages.firstIndex(of: page)
        else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return onboardPages.last
        }

        return onboardPages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        //возвращаем следующий (относительно переданного viewController) дочерний контроллер
        guard
            let page = viewController as? OnboardPageViewController,
            let viewControllerIndex = onboardPages.firstIndex(of: page)
        else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < onboardPages.count else {
            return onboardPages.first
        }

        return onboardPages[nextIndex]
    }

}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {

        if let currentViewController = pageViewController.viewControllers?
            .first as? OnboardPageViewController,
            let currentIndex = onboardPages.firstIndex(
                of: currentViewController
            )
        {
            pageControl.currentPage = currentIndex
        }
    }
}
