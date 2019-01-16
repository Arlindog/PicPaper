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

    func get<Object: Decodable>(seal: Resolver<Object>, url: String, parameters: Params?) {
        provider.get(seal: seal, url: url, parameters: parameters)
    }
}
