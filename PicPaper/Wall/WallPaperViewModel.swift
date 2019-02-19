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
        case (.idle, .idle):
            return true
        case (.loadingWallPaper, .loadingWallPaper):
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

protocol WallPaperViewModelDelegate: class {
    func showPhotoPermissionView()
}

class WallPaperViewModel: NSObject, ListAdapterDataSource, PictureSectionViewModelDelegate {
    private struct Constants {
        static let defaultPictureLimit: Int = 5
        static let startingWallPage: Int = 1
    }

    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        adapter.dataSource = self
        return adapter
    }()

    weak var delegate: WallPaperViewModelDelegate?

    private let trashBag = DisposeBag()
    private let dataManager = PixabayDataManager()

    private let wallPaperData = BehaviorRelay<[SectionViewModel]>(value: [])

    let requestState: BehaviorRelay<RequestState> = BehaviorRelay(value: .idle)
    private var currentWallPage = Constants.startingWallPage

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

    func requstWallPaperData(requestType: WallRequestType) {
        requestState.accept(.loadingWallPaper)

        let shouldResetWallPage: Bool
        switch requestType {
        case .standard:
            wallPaperData.accept([])
            shouldResetWallPage = true
        case .pullToRefresh:
            shouldResetWallPage = false
        case .pagination:
            shouldResetWallPage = false
        }

        if currentWallPage != Constants.startingWallPage && shouldResetWallPage {
            currentWallPage = Constants.startingWallPage
        }

        let params = RequestParams.buildParams(values: [
            .order(.popular),
            .safeSearch(true),
            .resultCount(Constants.defaultPictureLimit),
            .page(currentWallPage),
            .searchTerm(["wilderness"])
        ])

        dataManager.getPictures(parameters: params)
            .ensure { [weak self] in
                self?.requestState.accept(.idle)
            }
            .map(generateViewModels)
            .done { [weak self] wallpaperSectionViewModels in
                self?.handleWallPaperResponse(with: wallpaperSectionViewModels, requestType: requestType)
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

    private func handleWallPaperResponse(with sectionViewModels: [SectionViewModel], requestType: WallRequestType) {
        switch requestType {
        case .standard, .pullToRefresh:
            wallPaperData.accept(sectionViewModels)
        case .pagination:
            let updatedSectionViewModels = wallPaperData.value + sectionViewModels
            wallPaperData.accept(updatedSectionViewModels)
        }
        currentWallPage += 1
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
        guard PhotoLibraryManager.shared.isAuthorized else {
            // Show Photo Permission view
            delegate?.showPhotoPermissionView()
            return
        }

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
