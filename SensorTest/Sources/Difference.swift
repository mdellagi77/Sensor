//
//  Difference.swift
//  SensorTest
//
//  Created by Ferran Pujol Camins on 03/06/2019.
//  Copyright © 2019 Intelligent Apps GmbH. All rights reserved.
//

import Foundation

public enum Difference {
    case primitiveTypeDifference(valueLabel: String, expected: Any, recorded: Any)

    case singlePrimitiveChildrenDifference(valueLabel: String, childrenLabel: String, expectedChildren: Any, recordedChildren: Any)

    case childrenDifference(expectedLabel: String)

    case arrayDifference(expected: Any, value: Any)
}

public func diff<T>(_ expected: T, _ recorded: T, valueLabel: String) -> [Difference] {
    let expectedMirror = Mirror(reflecting: expected)
    let recordedMirror = Mirror(reflecting: recorded)
    // expected and recorded are the same type, so one is primitive if and only if the other is primitive also.
    if expectedMirror.isPrimitiveType {
        return [.primitiveTypeDifference(valueLabel: valueLabel, expected: expected, recorded: recorded)]
    } else {
        let expectedChildren = expectedMirror.enrichedChildren.filter { $0.label != nil }.sorted(by: { $0.label! < $1.label! })
        let recordedChildren = recordedMirror.enrichedChildren.filter { $0.label != nil }.sorted(by: { $0.label! < $1.label! })
        let values = Array(zip(expectedChildren, recordedChildren)).map { (expected: $0.0, recorded: $0.1) }
        let differences = values.filter {
            dump($0.expected.value) != dump($0.recorded.value) || $0.expected.label != $0.recorded.label
        }

        switch differences.count {
        case 0:
            return []
        case 1:
            let difference = differences.first!
            let expectedDifferenceMirror = Mirror(reflecting: difference.expected.value)
            let recordedDifferenceMirror = Mirror(reflecting: difference.recorded.value)
            if expectedDifferenceMirror.isPrimitiveType && recordedDifferenceMirror.isPrimitiveType {
                if case .enum? = expectedMirror.displayStyle,
                    difference.expected.label != difference.recorded.label {

                    // The enum case does not match
                    return [.primitiveTypeDifference(valueLabel: valueLabel, expected: difference.expected.label!, recorded: difference.recorded.label!)]
                } else {
                    return [.singlePrimitiveChildrenDifference(
                        valueLabel: valueLabel,
                        childrenLabel: difference.expected.label!,
                        expectedChildren: difference.expected.value,
                        recordedChildren: difference.recorded.value
                    )]
                }
            } else {
                return [.childrenDifference(expectedLabel: valueLabel)]
            }
        default:
            return [.childrenDifference(expectedLabel: valueLabel)]
        }
    }
}

public extension Mirror {
    // This property is just like children, but has additional logic to provide a "label" string in more cases, like dictionaries, enums or tuples.
    var enrichedChildren: Mirror.Children {
        guard let displayStyle = self.displayStyle else { return children }
        return AnyCollection(
            children.enumerated().flatMap { arg -> Mirror.Children in
                let index = arg.offset
                let child = arg.element
                let (label, childValue) = child


                switch displayStyle {

                case .struct, .class:
                    return AnyCollection([child])

                case .enum:
                    let mirror = Mirror(reflecting: childValue)
                    if mirror.isPrimitiveType {
                        return AnyCollection([child])
                    } else {
                        return mirror.enrichedChildren
                    }

                case .tuple:
                    return AnyCollection([(label: label ?? String(index), value: childValue)])

                case .optional:
                    return AnyCollection([child])

                case .collection:
                    return AnyCollection([child])

                case .dictionary:
                    let (key, value) = childValue as! (key: Any, value: Any)
                    return AnyCollection([(label: "\(key)", value: value)])
                    
                case .set:
                    return AnyCollection([child])

                @unknown default:
                    return AnyCollection([child])
                }
        })
    }

    var isPrimitiveType: Bool {
        return children.count == 0
    }
}

func dump(_ object: Any) -> String {
    var s = String()
    dump(object, to: &s)
    return s
}
