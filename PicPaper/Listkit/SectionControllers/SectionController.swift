//
//  SectionController.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class SectionController<ViewModel: SectionViewModel>: BaseSectionController, ListAdapterDataSource {

    var viewModel: ViewModel?

    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: viewController)
        adapter.dataSource = self
        return adapter
    }()

    override init() {
        super.init()
        inset = defaultInsets
    }

    override func didUpdate(to object: Any) {
        viewModel = object as? ViewModel
        setupViewModel()
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = context.dequeueReusableCell(of: SectionCell.self, for: self, at: index) as? SectionCell else { fatalError("Expecting Section Cell at index: \(index)") }

        adapter.collectionView = cell.collectionView
        return cell
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return contentSize
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return []
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        fatalError("Must overrride in subclasses")
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

    func setupViewModel() {
        viewModel?.adapter = adapter
    }
}
