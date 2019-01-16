//
//  Fetchable.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import PromiseKit

protocol Fetchable {
    func get<Object: Decodable>(seal: Resolver<Object>, url: String, parameters: Params?)
}
