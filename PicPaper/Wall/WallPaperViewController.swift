//
//  WallPaperViewController.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVPullToRefresh

class WallPaperViewController: UIViewController, WallPaperViewModelDelegate, DownloadingViewDelegate, PhotoPermissionViewDelegate {

    private let trashBag = DisposeBag()
    private let viewModel = WallPaperViewModel()

    private let activityIndicator = UIActivityIndicatorView(style: .white)

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    private let photoPermissionView = PhotoPermissionView()
    private let downloadingView = DownloadingView()
    private let refreshControl = UIRefreshControl()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadWall(requestType: .standard)

        guard !PhotoLibraryManager.shared.hasShownAutorizationPrompt else { return }
        PhotoLibraryManager.shared.hasShownAutorizationPrompt = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showPhotoPermissionView()
        }
    }

    private func setup() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .black
        setupCollectionView()
        setupActivityIndicator()
        setupDownloadingView()
        setupPermissionView()
        setupViewModel()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        [collectionView.topAnchor.constraint(equalTo: view.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
         collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }

        refreshControl.addTarget(self, action: #selector(performPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        collectionView.addInfiniteScrolling { [weak self] in
            self?.loadWall(requestType: .pagination)
        }
        collectionView.infiniteScrollingView.activityIndicatorViewStyle = .white

        viewModel.requestState.asDriver()
            .filter { $0 != .loadingWallPaper }
            .drive(onNext: { [unowned self] _ in
                self.collectionView.infiniteScrollingView.stopAnimating()
                self.refreshControl.endRefreshing()
            }).disposed(by: trashBag)
    }

    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        [activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ].forEach { $0.isActive = true }
    }

    func setupDownloadingView() {
        blurView.alpha = 0.0
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        [blurView.topAnchor.constraint(equalTo: view.topAnchor),
         blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
         blurView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }

        downloadingView.alpha = 0.0
        downloadingView.delegate = self
        downloadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadingView)
        [downloadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         downloadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         downloadingView.heightAnchor.constraint(equalToConstant: 250),
         downloadingView.widthAnchor.constraint(equalToConstant: 300)
        ].forEach { $0.isActive = true }
    }

    func setupViewModel() {
        viewModel.delegate = self
        viewModel.requestState.asDriver()
            .filter { !$0.isDownloading }
            .map { $0 == .loadingWallPaper }
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: trashBag)

        viewModel.requestState.asDriver()
            .filter { $0.isDownloading }
            .drive(onNext: showDownloadingView)
            .disposed(by: trashBag)

        viewModel.setViewController(self)
        viewModel.setCollectionView(collectionView)
    }

    func setupPermissionView() {
        photoPermissionView.alpha = 0.0
        photoPermissionView.delegate = self
        photoPermissionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoPermissionView)

        let permissionViewWidth: CGFloat = view.bounds.width - 32
        [photoPermissionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         photoPermissionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         photoPermissionView.heightAnchor.constraint(equalToConstant: permissionViewWidth),
         photoPermissionView.widthAnchor.constraint(equalToConstant: permissionViewWidth)
        ].forEach { $0.isActive = true }
    }

    // MARK: WallPaperViewModelDelegate

    func showPhotoPermissionView() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1.0
            self.photoPermissionView.alpha = 1.0
        }
    }

    func showDownloadingView(with requestState: RequestState) {
        guard case let .downloading(picutre) = requestState else { return }
        downloadingView.configure(with: viewModel.requestState.asObservable(), picture: picutre)

        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1.0
            self.downloadingView.alpha = 1.0
        }
    }

    @objc func performPullToRefresh() {
        loadWall(requestType: .pullToRefresh)
    }

    func loadWall(requestType: WallRequestType) {
        viewModel.requstWallPaperData(requestType: requestType)
    }

    // MARK: DownloadingViewDelegate

    func closeDownloadView() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0.0
            self.downloadingView.alpha = 0.0
        }
    }

    // MARK: PhotoPermissionViewDelegate

    func closePhotoPermissionView() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0.0
            self.photoPermissionView.alpha = 0.0
        }
    }
}
