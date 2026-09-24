//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 20.09.2026.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    // MARK: - override Properties
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 3 : 0
        }
    }
    
    // MARK: - UI Elements
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            colorView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
}
