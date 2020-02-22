//
//  SectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import RxDataSources

class SectionViewModel: NSObject, SectionItem, IdentifiableType {
    typealias Identity = String

    private let itemIdentity = UUID().uuidString

    var identity: String {
        return itemIdentity
    }

    var cellIdentifier: String {
        assertionFailure("Should be overwritten by subclasses")
        return UITableViewCell.identifier
    }

    func getSize(using contextWidth: CGFloat) -> CGSize { return .zero }
}
