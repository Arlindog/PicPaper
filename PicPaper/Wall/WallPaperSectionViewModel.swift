//
//  WallPaperSectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/25/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class WallPaperSectionViewModel: NSObject, SectionViewModel {

    var adapter: ListAdapter?

    var sectionController: BaseSectionController = WallPaperSectionController()

    let mediaContent: [SectionViewModel]

    init(mediacontent: [SectionViewModel]) {
        self.mediaContent = mediacontent
    }

    func getSize(using contextSize: CGSize) -> CGSize {
        let maxHeight = mediaContent.map { $0.getSize(using: contextSize).height }.max() ?? 0
        return CGSize(width: contextSize.width, height: maxHeight)
    }

    // MARK: ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
