//
//  OnboardPageViewController.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 29.09.2026.
//

import UIKit

final class OnboardPageViewController: UIViewController {
    private let backgroundImage: UIImage
    private let titleText: String

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(backgroundImage: UIImage, titleText: String) {
        self.backgroundImage = backgroundImage
        self.titleText = titleText

        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            backgroundImageView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            backgroundImageView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 76),
        ])
    }
}
