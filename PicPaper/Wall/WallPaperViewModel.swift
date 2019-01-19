//
//  WallPaperViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit
import RxSwift
import RxCocoa

class WallPaperViewModel: NSObject, ListAdapterDataSource, PictureSectionViewModelDelegate {
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        adapter.dataSource = self
        return adapter
    }()

    private let trashBag = DisposeBag()
    private let dataManager = PixabayDataManager()

    private let wallPaperData = BehaviorRelay<[SectionViewModel]>(value: [])

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        wallPaperData.asDriver()
            .drive(onNext: { [unowned self] _ in
                self.adapter.performUpdates(animated: false)
            }).disposed(by: trashBag)
    }

    func setViewController(_ viewController: UIViewController) {
        adapter.viewController = viewController
    }

    func setCollectionView(_ collectionView: UICollectionView) {
        adapter.collectionView = collectionView
    }

    func requstWallPaperData() {
        let params = RequestParams.buildParams(values: [
            .order(.popular),
            .safeSearch(true),
            .resultCount(100),
            .page(1),
            .searchTerm(["wilderness"])
        ])
        dataManager.getPictures(parameters: params)
            .done { [weak self] (picureContent) in
                if let wallpaperSectionViewModels = self?.generateViewModels(from: picureContent) {
                    self?.wallPaperData.accept(wallpaperSectionViewModels)
                }
            }.catch { error in
                print(error)
            }
    }

    private func generateViewModels(from contentItems: PixabayContentItem<PixabayPicture>) -> [WallPaperSectionViewModel] {
        return contentItems.items.map { (picture) in
            let pictureViewModel = PictureSectionViewModel(picture: picture)
            pictureViewModel.delegate = self
            return WallPaperSectionViewModel(mediacontent: [pictureViewModel])
        }
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return wallPaperData.value
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        guard let sectionViewModel = object as? SectionViewModel else {
            assertionFailure("Expecting a SectionViewModel")
            return ListSectionController()
        }
        return sectionViewModel.sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }

    // MARK: PictureSectionViewModelDelegate

    func savePicture(_ picture: PixabayPicture) {
        dataManager.downloadPicture(picture)
            .compactMap { UIImage(data: $0) }
            .done { image in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }.catch {
                print("Error downloading image: \($0)")
            }
    }
}
