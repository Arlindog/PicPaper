//
//  PixabayDataManager.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import RxSwift

class PixabayDataManager {

    let provider: Provider

    init(provider: Provider = NetworkProvider.shared) {
        self.provider = provider
    }

    func getPictures(parameters: Params) -> Single<PixabayContentItem<PixabayPicture>> {
        let url = Routes.url(for: .picture)
        return provider.get(url: url, parameters: parameters)
    }

    func downloadPicture(_ picture: PixabayPicture) -> Single<Data> {
        return provider.get(url: picture.imageUrl)
    }
}
