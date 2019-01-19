//
//  LocalFetchable.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import PromiseKit

class LocalFetchable: Fetchable {

    func get<Object: Decodable>(url: String, parameters: Params?) -> Promise<Object> {
        return Promise(error: NetworkProviderError.noData)
    }

    func get(url: String) -> Promise<Data> {
        return Promise(error: NetworkProviderError.noData)
    }
}
