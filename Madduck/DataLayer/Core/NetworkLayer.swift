//
//  NetworkLayer.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

typealias Parameters = [String : Any]

fileprivate enum URLEncoding {
    case queryString
    case none

    func encode(_ request: inout URLRequest, with parameters: Parameters)  {
        switch self {
        case .queryString:
            guard let url = request.url else { return }
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               !parameters.isEmpty {

                urlComponents.queryItems = [URLQueryItem]()
                for (k, v) in parameters {
                    let queryItem = URLQueryItem(name: k, value: "\(v)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                request.url = urlComponents.url
            }

        /// default case f
        case .none:
            break
        }
    }
}

protocol APIRequestProtocol {
    static func makeRequest<S: Codable>(session: URLSession, request: URLRequest, model: S.Type, completion: @escaping (Result<S?, Error>) -> Void)
    static func makeGetRequest<T: Codable> (path: String, queries: Parameters, completion: @escaping (Result<T, Error>) -> Void)
    static func makePostRequest<T: Codable> (path: String, body: Parameters, completion: @escaping (Result<T, Error>) -> Void)
}


enum APIRequestManager: APIRequestProtocol {
    case getAPI(path: String, data: Parameters)
    case postAPI(path: String, data: Parameters)

    static var baseURL: URL = URL(string: "https://api.github.com/")!

    private var path: String {
        switch self {
        case .getAPI(let path, _):
            return path
        case .postAPI(let path, _):
            return path
        }
    }

    private var method: HTTPMethod {
        switch self {
        case .getAPI:
            return .get
        case .postAPI:
            return .post
        }
    }

    // MARK:- Functions
    fileprivate func addHeaders(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    }

    fileprivate func asURLRequest() -> URLRequest {
        var request = URLRequest(url: Self.baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue

        var parameters = Parameters()

        switch self {
        case .getAPI(_, let queries):
            queries.forEach({parameters[$0] = $1})
            URLEncoding.queryString.encode(&request, with: parameters)

        case .postAPI(_, let queries):
            queries.forEach({parameters[$0] = $1})

            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = jsonData
            }
        }
        self.addHeaders(request: &request)
        return request
    }

    static func makeRequest<S: Codable>(session: URLSession, request: URLRequest, model: S.Type, completion: @escaping (Result<S?, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil, let responseData = data else { completion(.failure(NetworkError.apiFailure)); return }

            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    as? Parameters  {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(S.self, from: jsonData)

                    completion(.success(response))

                    /// if the response is an `Array of Objects`
                } else if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                            as? [Parameters] {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(S.self, from: jsonData)

                    completion(.success(response))

                }
                else {
                    completion(.failure(NetworkError.invalidResponse))
                    return

                }
            } catch {
                completion(.failure(NetworkError.decodingError))
                return

            }
        }.resume()
    }

    static func makeGetRequest<T: Codable> (path: String, queries: Parameters = [:], completion: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession.shared
        let request: URLRequest = Self.getAPI(path: path, data: queries).asURLRequest()

        makeRequest(session: session, request: request, model: T.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    completion(.failure(error))

                case .success(let data):
                    if let data {
                        completion(.success(data))
                    } else {
                        completion(.failure(ServiceError.unexpectedResponse))
                    }

                }
            }
        }
    }

    static func makePostRequest<T: Codable> (path: String, body: Parameters, completion: @escaping (Result<T, Error>) -> Void) {
        let session = URLSession.shared
        let request: URLRequest = Self.postAPI(path: path, data: body).asURLRequest()

        makeRequest(session: session, request: request, model: T.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    completion(.failure(error))

                case .success(let data):
                    if let data {
                        completion(.success(data))
                    } else {
                        completion(.failure(ServiceError.unexpectedResponse))
                    }

                }
            }
        }
    }
}

struct NetworkManager {

    static let shared = NetworkManager()

}
