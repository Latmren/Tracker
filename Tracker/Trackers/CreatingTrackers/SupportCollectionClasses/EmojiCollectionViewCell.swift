//
//  EmojiCollectionViewCell.swift
//  Alphabet
//
//  Created by Dmitry Zherebyatnikov on 11.09.2026.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - override Properties
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .ypLightGray : .ypWhite
        }
    }
    
    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
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


    
    // MARK: - Public Methods

    func configure(with emoji: String) {
        titleLabel.text = emoji
    }

}
