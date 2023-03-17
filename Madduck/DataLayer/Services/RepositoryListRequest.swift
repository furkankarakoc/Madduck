//
//  RepositoryListRequest.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

// MARK: - Repository List Service
extension NetworkManager {

    func getRepositoryList(completion: @escaping (Result<[Repository], Error>) -> Void) {
        APIRequestManager.makeGetRequest(path: "orgs/google/repos", completion: completion)
    }

}
