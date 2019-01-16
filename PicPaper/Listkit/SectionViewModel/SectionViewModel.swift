//
//  SectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

protocol SectionViewModel: ListDiffable {
    var adapter: ListAdapter? { get set }
    var sectionController: BaseSectionController { get }

    func getSize(using contextSize: CGSize) -> CGSize
}
