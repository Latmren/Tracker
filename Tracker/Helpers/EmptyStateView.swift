//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 04.10.2026.
//

import UIKit

final class EmptyStateView: UIView {

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    init(
        image: UIImage?,
        text: String
    ) {
        super.init(frame: .zero)

        imageView.image = image
        label.text = text

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Setup

    private func setupView() {
        addSubview(imageView)
        addSubview(label)

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            imageView.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),

            label.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: 8
            ),
            label.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            label.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            label.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
        ])
    }
}
