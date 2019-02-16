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

    var hasRequestedAutorization: Bool {
        return UserDefaults.standard.hasRequestedPhotoLibraryAutorization
    }

    var isAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    func requestAuthorization() -> Observable<Bool> {
        guard !isAuthorized else { return Observable.just(true) }
        if !hasRequestedAutorization {
            UserDefaults.standard.hasRequestedPhotoLibraryAutorization = true
        }
        return Observable.create { (obserable) in
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    obserable.on(.next(true))
                case .denied, .restricted, .notDetermined:
                    obserable.on(.next(false))
                }
            }
            return Disposables.create()
        }
    }
}

fileprivate extension UserDefaults {
    private var photoLibraryAutorizationKey: String {
        return "com.PicPaper.PhotoLibraryAutorization"
    }

    fileprivate var hasRequestedPhotoLibraryAutorization: Bool {
        get {
            return UserDefaults.standard.bool(forKey: photoLibraryAutorizationKey)
        }
        set {
            UserDefaults.standard.set(true, forKey: photoLibraryAutorizationKey)
        }
    }
}
