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

enum RequestState: Equatable {
    static func == (lhs: RequestState, rhs: RequestState) -> Bool {
        switch (lhs, rhs) {
        case (.downloading, .downloading):
            return true
        case (.idle,.idle):
            return true
        case (.loadingWallPaper,.loadingWallPaper):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }

    case idle
    case loadingWallPaper
    case downloading(PixabayPicture)
    case error(Error)

    var isDownloading: Bool {
        switch self {
        case .downloading:
            return true
        default:
            return false
        }
    }
}

class WallPaperViewModel: NSObject, ListAdapterDataSource, PictureSectionViewModelDelegate {
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        adapter.dataSource = self
        return adapter
    }()

    private let trashBag = DisposeBag()
    private let dataManager = PixabayDataManager()

    private let wallPaperData = BehaviorRelay<[SectionViewModel]>(value: [])

    let requestState: BehaviorRelay<RequestState> = BehaviorRelay(value: .idle)

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
        requestState.accept(.loadingWallPaper)
        dataManager.getPictures(parameters: params)
            .ensure { [weak self] in
                self?.requestState.accept(.idle)
            }.done { [weak self] (picureContent) in
                if let wallpaperSectionViewModels = self?.generateViewModels(from: picureContent) {
                    self?.wallPaperData.accept(wallpaperSectionViewModels)
                }
            }.catch { [weak self] error in
                self?.requestState.accept(.error(error))
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
        requestState.accept(.downloading(picture))
        dataManager.downloadPicture(picture)
            .ensure { [weak self] in
                self?.requestState.accept(.idle)
            }.compactMap {
                UIImage(data: $0)
            }.done { image in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }.catch { [weak self] error in
                print("Error downloading image: \(error)")
                self?.requestState.accept(.error(error))
            }
    }
}
