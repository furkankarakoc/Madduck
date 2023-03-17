//
//  Sequence.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = (<)) -> [Element] {
            sorted { a, b in
                comparator(a[keyPath: keyPath], b[keyPath: keyPath])
            }
        }
}
