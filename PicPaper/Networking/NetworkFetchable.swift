//
//  NetworkFetchable.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import PromiseKit

class NetworkFetchable: Fetchable {

    let provider = NetworkProvider()

    func get<Object: Decodable>(url: String, parameters: Params?) -> Promise<Object> {
        return Promise { seal in
            provider.get(seal: seal, url: url, parameters: parameters)
        }
    }

    func get(url: String) -> Promise<Data> {
        return Promise { seal in
            provider.get(url: url) { (response) in
                seal.resolve(response.error, response.data)
            }
        }
    }
}
