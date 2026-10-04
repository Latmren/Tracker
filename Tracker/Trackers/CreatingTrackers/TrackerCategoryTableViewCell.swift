//
//  TrackerCategoryTableViewCell.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 02.10.2026.
//

import UIKit

final class TrackerCategoryTableViewCell: UITableViewCell {
    //MARK: - Properties

    static let reuseIdentifier = "TrackerCategoryTableViewCell"

    //MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupView() {
        backgroundColor = .ypBackgroundDay

        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = .ypBlackDay

        selectionStyle = .none

        separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
    }

    func configure(
        title: String,
        isSelected: Bool
    ) {
        textLabel?.text = title
        accessoryType = isSelected ? .checkmark : .none
    }
}
