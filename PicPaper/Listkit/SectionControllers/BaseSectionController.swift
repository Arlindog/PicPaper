//
//  BaseSectionController.swift
//  PicPaper
//
//  Created by Arlindo on 8/25/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class BaseSectionController: ListSectionController {
    var context: ListCollectionContext {
        return collectionContext!
    }

    var contentSize: CGSize {
        return context.containerSize
    }

    var defaultInsets: UIEdgeInsets {
        return .zero
    }
}
