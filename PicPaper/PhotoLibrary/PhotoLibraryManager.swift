//
//  PhotoLibraryManager.swift
//  PicPaper
//
//  Created by Arlindo on 1/20/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import Photos

class PhotoLibraryManager {

    static let shared = PhotoLibraryManager()
    private init() {}

    var hasShownAutorizationPrompt: Bool {
        get {
            return UserDefaults.standard.hasShownPhotoLibraryAutorizationPrompt
        }
        set {
            UserDefaults.standard.hasShownPhotoLibraryAutorizationPrompt = newValue
        }
    }

    var status: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    var isAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    var isDenied: Bool {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        return authorizationStatus == .denied || authorizationStatus == .restricted
    }

    func requestAuthorization() -> Observable<PHAuthorizationStatus> {
        guard !isAuthorized else { return Observable.just(.authorized) }
        return Observable.create { (obserable) in
            PHPhotoLibrary.requestAuthorization { status in
                obserable.on(.next(status))
            }
            return Disposables.create()
        }
    }
}

fileprivate extension UserDefaults {
    private var photoLibraryAutorizationKey: String {
        return "com.PicPaper.hasShownPhotoLibraryAutorizationPrompt"
    }

    fileprivate var hasShownPhotoLibraryAutorizationPrompt: Bool {
        get {
            return UserDefaults.standard.bool(forKey: photoLibraryAutorizationKey)
        }
        set {
            UserDefaults.standard.set(true, forKey: photoLibraryAutorizationKey)
        }
    }
}
