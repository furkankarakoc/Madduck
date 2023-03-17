//
//  RepositoryDetailRequest.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

extension NetworkManager {

    func getRepositoryDetail(name: String, completion: @escaping (Result<Repository, Error>) -> Void) {
        APIRequestManager.makeGetRequest(path: "repos/google/\(name)", completion: completion)
        
    }

}
