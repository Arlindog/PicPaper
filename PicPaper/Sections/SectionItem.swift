//
//  SectionItem.swift
//  PicPaper
//
//  Created by Arlindo on 2/22/20.
//  Copyright © 2020 DevByArlindo. All rights reserved.
//

import UIKit

protocol SectionItem {
    var cellIdentifier: String { get }
    func getSize(using contextWidth: CGFloat) -> CGSize
}
