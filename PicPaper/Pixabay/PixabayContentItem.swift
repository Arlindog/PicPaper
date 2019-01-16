//
//  PixabayContentItem.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Foundation

struct PixabayContentItem<T: Decodable>: Decodable {

    enum CodingKeys: String, CodingKey {
        case total
        case totalHits
        case items = "hits"
    }

    let total: Int
    let totalHits: Int
    let items: [T]
}
