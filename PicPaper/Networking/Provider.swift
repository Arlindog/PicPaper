//
//  Provider.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import RxSwift

protocol Provider {
    func get<Object: Decodable>(url: String, parameters: Params?) -> Single<Object>
    func get(url: String) -> Single<Data>
}
