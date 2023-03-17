//
//  Date.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

extension Date {
    var timestampValue: UInt64 {
        return UInt64((self.timeIntervalSince1970 * 1000))
    }

}
