//
//  UIColorValueTransformer.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 05.11.2026.
//

import UIKit

@objc(UIColorValueTransformer)
final class UIColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    override static var allowedTopLevelClasses: [AnyClass] {
        super.allowedTopLevelClasses + [UIColor.self]
    }
}
