//
//  NetworkProvider.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Alamofire
import RxSwift

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

class NetworkProvider: Provider {

    static let shared = NetworkProvider()

    private let manager: Session

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        manager = Alamofire.Session(configuration: configuration)
    }

    func get(url: String) -> Single<Data> {
        return Single.create { [weak self] task in
            guard let self = self else { return  Disposables.create() }
            let request = self.get(url: url) { response in
                if let error = response.error {
                    task(.error(NetworkProviderError.networkError(error)))
                    return
                }

                guard let data = response.data else {
                    task(.error(NetworkProviderError.noData))
                    return
                }

                task(.success(data))
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func get<Object: Decodable>(url: String, parameters: Params? = nil) -> Single<Object> {
        return Single.create { [weak self] task in
            guard let self = self else { return  Disposables.create() }
            let request = self.get(url: url, parameters: parameters) { response in
                if let error = response.error {
                    task(.error(NetworkProviderError.networkError(error)))
                    return
                }

                guard let data = response.data else {
                    task(.error(NetworkProviderError.noData))
                    return
                }

                do {
                    let decodableObject = try JSONDecoder().decode(Object.self, from: data)
                    task(.success(decodableObject))
                } catch let error {
                    print("Decoding Error: \(error)")
                    let stringValue = String(data: data, encoding: .utf8)
                    task(.error(NetworkProviderError.unableToDecode(stringValue ?? "")))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    private func get(url: String, parameters: Params? = nil, completion: @escaping (AFDataResponse<Data>) -> Void) -> DataRequest {
        return manager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseData { completion($0) }
    }
}
