//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 13.09.2026.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties

    weak var delegate: TrackerCollectionViewCellDelegate?

    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    // MARK: - UI Elements

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter
    }()

    private let completeButton: UIButton = {
        let button = UIButton()

        button.setImage(
            UIImage(systemName: "plus"),
            for: .normal
        )
        button.tintColor = .white
        button.layer.cornerRadius = 17

        button.translatesAutoresizingMaskIntoConstraints = false
        return button

    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()

        completeButton.addTarget(
            self,
            action: #selector(completeButtonTapped),
            for: .touchUpInside
        )

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(cardView)

        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)

        cardView.addSubview(titleLabel)

        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //Card
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            // Emoji
            emojiBackgroundView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 12
            ),
            emojiBackgroundView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(
                equalTo: emojiBackgroundView.centerXAnchor
            ),
            emojiLabel.centerYAnchor.constraint(
                equalTo: emojiBackgroundView.centerYAnchor
            ),

            // Tracker title
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -12
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -12
            ),

            // Number of completed days
            daysLabel.topAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: 16
            ),
            daysLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),

            // + button
            completeButton.centerYAnchor.constraint(
                equalTo: daysLabel.centerYAnchor
            ),
            completeButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),

        ])
    }

    func configure(
        with tracker: Tracker,
        completedDays: Int,
        isCompleted: Bool
    ) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title

        cardView.backgroundColor = tracker.color
        completeButton.backgroundColor = tracker.color

        var components = DateComponents()
        components.day = completedDays

        daysLabel.text = daysFormatter.string(from: components)

        let imageName = isCompleted ? "checkmark" : "plus"

        completeButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }

    @objc
    private func completeButtonTapped() {
        delegate?.trackerCellDidTapComplete(self)
    }
}
