//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 20.09.2026.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
