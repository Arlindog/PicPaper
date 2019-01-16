//
//  ViewController.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {

    let dataManager = PixaBayDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        let params = RequestParams.buildParams(values: [
            .order(.popular),
            .safeSearch(true),
            .resultCount(1),
            .page(0),
            .searchTerm(["Soccer"])
        ])
        dataManager.getPictures(paramerts: params)
            .done { (picure) in
                print(picure)
            }.catch { error in
                print(error)
            }
    }
}
