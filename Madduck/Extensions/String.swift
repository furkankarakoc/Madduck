//
//  String.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    var integerValue: Int {
        return Int(self) ?? 0
    }

    func convertToDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self)
    }

}
