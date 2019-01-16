//
//  ViewController.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit
import PromiseKit
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    let dataManager = PixabayDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        let params = RequestParams.buildParams(values: [
            .order(.popular),
            .safeSearch(true),
            .resultCount(3),
            .page(1),
            .searchTerm(["Soccer"])
        ])
        dataManager.getPictures(parameters: params)
            .done { [weak self] (picureItems) in
                if let picture = picureItems.items.first {
                    self?.updateImage(with: picture.previewUrl)
                }
            }.catch { error in
                print(error)
            }
    }

    func updateImage(with url: String) {
        imageView.sd_setImage(with: URL(string: url))
    }
}
