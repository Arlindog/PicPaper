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

class WallPaperViewController: UIViewController, DownloadingViewDelegate {

    private let trashBag = DisposeBag()
    private let viewModel = WallPaperViewModel()

    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    private let downloadingView = DownloadingView()

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
    }

    private func setup() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .black
        setupCollectionView()
        setupActivityIndicator()
        setupDownloadingView()
        setupViewModel()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        [collectionView.topAnchor.constraint(equalTo: view.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
         collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }
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
        viewModel.requestState
            .filter { !$0.isDownloading }
            .map { $0 == .loadingWallPaper }
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: trashBag)

        viewModel.requestState.asObservable()
            .filter { $0.isDownloading }
            .bind(onNext: showDownloadingView)
            .disposed(by: trashBag)

        viewModel.setViewController(self)
        viewModel.setCollectionView(collectionView)
        viewModel.requstWallPaperData()
    }

    func showDownloadingView(with requestState: RequestState) {
        guard case let .downloading(picutre) = requestState else { return }
        downloadingView.configure(with: viewModel.requestState.asObservable(), picture: picutre)

        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1.0
            self.downloadingView.alpha = 1.0
        }
    }

    // MARK: DownloadingViewDelegate

    func closeDownloadView() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0.0
            self.downloadingView.alpha = 0.0
        }
    }
}
