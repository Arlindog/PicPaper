//
//  Routes.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Foundation

struct Routes {
    private struct Contants {
        static let pixbayBaseUrl: String = "https://pixabay.com/api/"
        static let pixbayUserBaseUrl: String = "https://pixabay.com/users/"

        static let vimeoStaticVideoImageBaseUrl: String = "https://i.vimeocdn.com/video/"
    }

    enum Endpoint {
        case picture
        case video
        case user(String, String)
        case staticVideoImage(String, String)

        var url: String {
            switch self {
            case .picture:
                return Contants.pixbayBaseUrl
            case .video:
                return Contants.pixbayBaseUrl + "videos/"
            case .user(let username, let id):
                return Contants.pixbayUserBaseUrl + "\(username)-\(id)/"
            case .staticVideoImage(let pictureId, let size):
                return Contants.vimeoStaticVideoImageBaseUrl + "\(pictureId)_\(size)/"
            }
        }
    }

    static func url(for endpoint: Endpoint) -> String {
        return endpoint.url
    }
}
