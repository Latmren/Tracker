//
//  TrackerCollectionHeaderView.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 14.09.2026.
//

import UIKit

final class TrackerCollectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "TrackerCollectionHeaderView"

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 28
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor
            )
        ])
    }

    // MARK: - Configuration

    func configure(with title: String) {
        titleLabel.text = title
    }
}
