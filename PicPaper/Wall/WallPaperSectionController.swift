//
//  WallPaperSectionController.swift
//  PicPaper
//
//  Created by Arlindo on 8/25/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class WallPaperSectionController: SectionController<WallPaperSectionViewModel> {

    override var defaultInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let adjustedSize = CGSize(width: contentSize.width - inset.left - inset.right, height: contentSize.height + inset.bottom + inset.top)
        return viewModel?.getSize(using: adjustedSize) ?? .zero
    }

    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel?.mediaContent ?? []
    }

    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let sectionViewModel = object as? SectionViewModel else {
            assertionFailure("Expecting a SectionViewModel")
            return ListSectionController()
        }
        return sectionViewModel.sectionController
    }
}
