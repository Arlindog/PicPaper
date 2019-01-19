//
//  PixabayPicture.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Foundation

struct PixabayPicture: Decodable {

    enum CodingKeys: String, CodingKey {
        case fullPageUrl = "pageURL"
        case id
        case imageUrl = "largeImageURL"
        case imageWidth
        case imageHeight
        case previewUrl = "previewURL"
        case previewWidth
        case previewHeight
        case username = "user"
        case userId = "user_id"
        case userImageUrl = "userImageURL"
    }

    let fullPageUrl: String

    let id: Int
    let imageUrl: String
    let imageWidth: Int
    let imageHeight: Int

    let previewUrl: String
    let previewWidth: Int
    let previewHeight: Int

    let username: String
    let userId: Int
    let userImageUrl: String

    var userProfileUrl: String {
        return Routes.url(for: .user(username, userId))
    }
}
