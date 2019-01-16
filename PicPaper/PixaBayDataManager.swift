//
//  PixaBayDataManager.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import PromiseKit

class PixaBayDataManager {

    let fetchable: Fetchable

    init(fetchable: Fetchable = NetworkFetchable()) {
        self.fetchable = fetchable
    }

    func getPictures(paramerts: Params) -> Promise<String> {
        let url = Routes.url(for: .picture)
        return Promise { seal in
            fetchable.get(seal: seal, url: url, parameters: paramerts)
        }
    }

    func getVideos(paramerts: Params) -> Promise<String> {
        let url = Routes.url(for: .video)
        return Promise { seal in
            fetchable.get(seal: seal, url: url, parameters: paramerts)
        }
    }

    func getStaticVideoImage(videoId: String, size: String) -> Promise<String> {
        let url = Routes.url(for: .staticVideoImage(videoId, size))
        return Promise { seal in
            fetchable.get(seal: seal, url: url, parameters: nil)
        }
    }
}
