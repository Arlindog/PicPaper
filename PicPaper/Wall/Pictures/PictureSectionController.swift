//
//  PictureSectionController.swift
//  PicPaper
//
//  Created by Arlindo on 8/26/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class PictureSectionController: SectionController<PictureSectionViewModel> {

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = context.dequeueReusableCell(withNibName: PictureCell.defaultIdentifier, bundle: nil, for: self, at: index)
        if let cell = cell as? PictureCell,
            let viewModel = viewModel {
            cell.configure(with: viewModel)
        }
        return cell
    }
}
