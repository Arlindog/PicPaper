//
//  RequestState.swift
//  PicPaper
//
//  Created by Arlindo on 2/22/20.
//  Copyright © 2020 DevByArlindo. All rights reserved.
//

import Foundation

enum RequestState: Equatable {
    static func == (lhs: RequestState, rhs: RequestState) -> Bool {
        switch (lhs, rhs) {
        case (.downloading, .downloading):
            return true
        case (.idle, .idle):
            return true
        case (.loadingWallPaper, .loadingWallPaper):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }

    case idle
    case loadingWallPaper
    case downloading(PixabayPicture)
    case error(Error)

    var isDownloading: Bool {
        if case .downloading = self {
            return true
        } else {
            return false
        }
    }
}
