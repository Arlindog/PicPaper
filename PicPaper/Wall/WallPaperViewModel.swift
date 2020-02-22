//
//  WallPaperViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

protocol WallPaperViewModelDelegate: class {
    func showPhotoPermissionView()
}

class WallPaperViewModel: NSObject, PictureSectionViewModelDelegate {
    private struct Constants {
        static let defaultPictureLimit: Int = 5
        static let startingWallPage: Int = 1
    }

    weak var delegate: WallPaperViewModelDelegate?

    private let trashBag = DisposeBag()
    private let dataManager = PixabayDataManager()

    private let wallPaperData = BehaviorRelay<[SectionViewModel]>(value: [])

    let requestState: BehaviorRelay<RequestState> = BehaviorRelay(value: .idle)
    private var currentSearchTerm = BehaviorRelay<String?>(value: nil)
    private var currentWallPage = Constants.startingWallPage

    var searchTerm: Driver<String?> {
        return currentSearchTerm.asDriver()
    }

    var wallPaperDataDriver: Driver<[SectionViewModel]> {
        return wallPaperData.asDriver()
    }

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        currentSearchTerm
            // skip the initial value
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                self.requstWallPaperData(requestType: .standard)
            }).disposed(by: trashBag)
    }

    func configure(with searchBarViewModel: SearchBarViewModel) {
        searchBarViewModel.currentSearchTerm
            // skip the initial value
            .skip(1)
            .bind(to: currentSearchTerm)
            .disposed(by: trashBag)
    }

    func requstWallPaperData(requestType: RequestType) {
        let shouldResetWallPage: Bool
        switch requestType {
        case .standard:
            wallPaperData.accept([])
            requestState.accept(.loadingWallPaper)
            shouldResetWallPage = true
        case .pullToRefresh:
            shouldResetWallPage = false
            requestState.accept(.loadingWallPaper)
        case .pagination:
            shouldResetWallPage = false
        }

        if currentWallPage != Constants.startingWallPage && shouldResetWallPage {
            currentWallPage = Constants.startingWallPage
        }

        var paramsValues: [RequestParams.ParamValues] = [
            .order(.popular),
            .safeSearch(true),
            .resultCount(Constants.defaultPictureLimit),
            .page(currentWallPage)
        ]

        if let searchTerm = currentSearchTerm.value,
            !searchTerm.isEmpty {
            paramsValues.append(.searchTerm([searchTerm]))
        }

        let params = RequestParams.buildParams(values: paramsValues)

        dataManager.getPictures(parameters: params)
            .subscribe { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .success(let contentItems):
                    let sectionViewModels = self.generateViewModels(from: contentItems)
                    self.handleWallPaperResponse(with: sectionViewModels, requestType: requestType)
                    self.requestState.accept(.idle)
                case .error(let error):
                    print("Error downloading image: \(error)")
                    self.requestState.accept(.error(error))
                }
            }
            .disposed(by: trashBag)
    }

    func clearSearchTerm() {
        currentSearchTerm.accept(nil)
    }

    private func generateViewModels(from contentItems: PixabayContentItem<PixabayPicture>) -> [SectionViewModel] {
        return contentItems.items.map { (picture) in
            let pictureViewModel = PictureSectionViewModel(picture: picture)
            pictureViewModel.delegate = self
            return pictureViewModel
        }
    }

    private func handleWallPaperResponse(with sectionViewModels: [SectionViewModel], requestType: RequestType) {
        switch requestType {
        case .standard, .pullToRefresh:
            wallPaperData.accept(sectionViewModels)
        case .pagination:
            let updatedSectionViewModels = wallPaperData.value + sectionViewModels
            wallPaperData.accept(updatedSectionViewModels)
        }
        currentWallPage += 1
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
            .subscribe { [weak self] in
                switch $0 {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    self?.requestState.accept(.idle)
                case .error(let error):
                    print("Error downloading image: \(error)")
                    self?.requestState.accept(.error(error))
                }
            }
            .disposed(by: trashBag)
    }

    func getSectionSize(for indexPath: IndexPath, contextWidth: CGFloat) -> CGSize {
        guard let sectionViewModel = wallPaperData.value[safely: indexPath.row] else { return .zero }
        return sectionViewModel.getSize(using: contextWidth)
    }
}
