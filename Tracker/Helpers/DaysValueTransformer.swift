//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 21.09.2026.
//
import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<WeekDay> else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode(Set<WeekDay>.self, from: data as Data)
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(
                rawValue: String(describing: DaysValueTransformer.self)
            )
        )
    }
}
