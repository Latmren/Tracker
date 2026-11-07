//
//  GradientBorderView.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 30.10.2026.
//

import UIKit

final class GradientBorderView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    private let borderWidth: CGFloat = 1
    private let borderRadius: CGFloat = 18

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .ypWhite
        layer.cornerRadius = borderRadius
        layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor,
        ]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.strokeColor = UIColor.black.cgColor
        borderMask.lineWidth = borderWidth

        gradientLayer.mask = borderMask

        layer.addSublayer(gradientLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        borderMask.frame = gradientLayer.bounds

        let inset = borderWidth / 2

        borderMask.path =
            UIBezierPath(
                roundedRect: bounds.insetBy(
                    dx: inset,
                    dy: inset
                ),
                cornerRadius: borderRadius - inset
            ).cgPath
    }
}
