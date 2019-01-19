//
//  PixabayDataManager.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import PromiseKit

class PixabayDataManager {

    let fetchable: Fetchable

    init(fetchable: Fetchable = NetworkFetchable()) {
        self.fetchable = fetchable
    }

    func getPictures(parameters: Params) -> Promise<PixabayContentItem<PixabayPicture>> {
        let url = Routes.url(for: .picture)
        return fetchable.get(url: url, parameters: parameters)
    }

    func downloadPicture(_ picture: PixabayPicture) -> Promise<Data> {
        return fetchable.get(url: picture.imageUrl)
    }

    func getVideos(parameters: Params) -> Promise<String> {
        let url = Routes.url(for: .video)
        return Promise { seal in
            // TODO: REquest Videos
        }
    }

    func getStaticVideoImage(videoId: String, size: String) -> Promise<String> {
        let url = Routes.url(for: .staticVideoImage(videoId, size))
        return Promise { seal in
            // TODO: Request Video Images for preview
        }
    }
}
