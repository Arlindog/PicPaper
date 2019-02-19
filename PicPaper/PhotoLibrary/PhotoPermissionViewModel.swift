//
//  PhotoPermissionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 2/17/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa
import Photos

protocol PhotoPermissionViewModelDelegate: class {
    func closePermission()
}

class PhotoPermissionViewModel {
    private struct Constants {
        static let defaultPermissionTitle: String = "We need your permission to save pictures to your photo library"
        static let defaultPermissionPrompt: String = "Give Permission 👍"

        static let authorizedPermissionTitle: String = "Thank You!"
        static let authorizedPermissionPrompt: String = "Authorized 😉"

        static let notAuthorizedPermissionTitle: String = "Photo Permission is Denied 😱. Open Settings and give access to your Photo Library."
        static let notAuthorizedPermissionPrompt: String = "Open Settings ⚙️"

        static let isAuthorizedColor: UIColor = UIColor(red: 105/255, green: 173/255, blue: 255/255, alpha: 1.0)
        static let notAuthorizedColor: UIColor = UIColor(red: 255/255, green: 38/255, blue: 0/255, alpha: 1.0)
    }

    private let trashBag = DisposeBag()
    weak var delegate: PhotoPermissionViewModelDelegate?

    private let authorizationStatus = BehaviorRelay<PHAuthorizationStatus>(value: PhotoLibraryManager.shared.status)

    var isAuthorized: Driver<Bool> {
        return authorizationStatus.asDriver()
            .map { $0 == .authorized }
    }

    var permissionTitle: Driver<String> {
        return authorizationStatus.asDriver()
            .map(getPermissionTitle)
    }

    var permissionPrompt: Driver<String> {
        return authorizationStatus.asDriver()
            .map(getPermissionPrompt)
    }

    var permissionColor: Driver<UIColor> {
        return authorizationStatus.asDriver()
            .map(getPermissionColor)
    }

    func promptPressed() {
        switch authorizationStatus.value {
        case .authorized:
            delegate?.closePermission()
        case .denied, .restricted:
            guard let settingUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            delegate?.closePermission()
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        case .notDetermined:
            requestPermission()
        }
    }

    private func requestPermission() {
        PhotoLibraryManager.shared.requestAuthorization()
            .bind(to: authorizationStatus)
            .disposed(by: trashBag)
    }

    func getPermissionTitle(for status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return Constants.authorizedPermissionTitle
        case .denied, .restricted:
            return Constants.notAuthorizedPermissionTitle
        case .notDetermined:
            return Constants.defaultPermissionTitle
        }
    }

    func getPermissionPrompt(for status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return Constants.authorizedPermissionPrompt
        case .denied, .restricted:
            return Constants.notAuthorizedPermissionPrompt
        case .notDetermined:
            return Constants.defaultPermissionPrompt
        }
    }

    func getPermissionColor(for status: PHAuthorizationStatus) -> UIColor {
        switch status {
        case .authorized, .notDetermined:
            return Constants.isAuthorizedColor
        case .denied, .restricted:
            return Constants.notAuthorizedColor
        }
    }
}
