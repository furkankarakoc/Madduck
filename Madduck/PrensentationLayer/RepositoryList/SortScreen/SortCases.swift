//
//  SortCases.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

enum SortCase: CaseIterable, Comparable {
    case size
    case forkCount
    case starCount
    case watcherCount
    case createdTime
    case updatedTime
    case alphabetically

    var description: String {
        switch self {
        case .size:
            return "Size".localized
        case .forkCount:
            return "Fork Count".localized
        case .starCount:
            return "Star Count".localized
        case .watcherCount:
            return "Watcher Count".localized
        case .createdTime:
            return "Created Time".localized
        case .updatedTime:
            return "Updated Time".localized
        case .alphabetically:
            return "Alphabetically".localized
        }
    }
}
