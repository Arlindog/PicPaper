//
//  NetworkProvider.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Alamofire
import PromiseKit

enum NetworkProviderError: Error, CustomStringConvertible {
    case noData
    case networkError(Error)
    case unableToDecode(Any)

    var description: String {
        switch self {
        case .noData:
            return "Response Data was empty"
        case .unableToDecode(let object):
            return "Unable to Decode Object: \(object)"
        case .networkError(let error):
            return "Network Error: \(error)"
        }
    }
}

class NetworkProvider {

    private let manager: Session

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        manager = Alamofire.Session(configuration: configuration)
    }

    func get(url: String, parameters: Params? = nil, completion: @escaping (AFDataResponse<Data>) -> Void) {
        manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseData { completion($0) }
    }

    func get<Object: Decodable>(seal: Resolver<Object>, url: String, parameters: Params? = nil) {
        get(url: url, parameters: parameters) { response in
            if let error = response.error {
                seal.reject(NetworkProviderError.networkError(error))
                return
            }

            guard let data = response.data else {
                seal.reject(NetworkProviderError.noData)
                return
            }

            do {
                let decodableObject = try JSONDecoder().decode(Object.self, from: data)
                seal.fulfill(decodableObject)
            } catch let error {
                print("Decoding Error: \(error)")
                let stringValue = String(data: data, encoding: .utf8)
                seal.reject(NetworkProviderError.unableToDecode(stringValue ?? ""))
            }
        }
    }
}
