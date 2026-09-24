//
//  EmojiCollectionViewCell.swift
//  Alphabet
//
//  Created by Dmitry Zherebyatnikov on 11.09.2026.
//

import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
