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
    private struct Constants {
        static let searchBarHeight: CGFloat = 40
        static let searchBarPadding: CGFloat = 8
        static let searchTermPrefix: String = "Searching: "
    }

    private let trashBag = DisposeBag()
    private let viewModel = WallPaperViewModel()

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    private let photoPermissionView = PhotoPermissionView()
    private let downloadingView = DownloadingView()
    private let refreshControl = UIRefreshControl()
    private let headerBar = UIView()
    private let searchBar = SearchBar(barHeight: Constants.searchBarHeight)

    private let searchTermLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()

    private let clearSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "refresh"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = Constants.searchBarHeight / 2
        button.backgroundColor = Colors.DarkTheme.primary
        return button
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObserver()
    }

    private func setup() {
        setupHeaderBar()
        setupCollectionView()
        setupSearchBar()
        setupDownloadingView()
        setupPermissionView()
        setupViewModel()
    }

    private func setupHeaderBar() {
        headerBar.backgroundColor = Colors.DarkTheme.primary
        view.addSubview(headerBar)
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        [headerBar.topAnchor.constraint(equalTo: view.topAnchor),
         headerBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         headerBar.leftAnchor.constraint(equalTo: view.leftAnchor),
         headerBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }
    }

    private func setupCollectionView() {
        collectionView.keyboardDismissMode = .interactive
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

    private func setupSearchBar() {
        view.addSubview(searchBar)
        view.addSubview(clearSearchButton)
        view.addSubview(searchTermLabel)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        [searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.searchBarPadding),
         searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.searchBarPadding),
         searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.searchBarPadding),
         searchBar.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight)
        ].forEach { $0.isActive = true }

        clearSearchButton.alpha = 0.0
        [clearSearchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.searchBarPadding),
         clearSearchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.searchBarPadding),
         clearSearchButton.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight),
         clearSearchButton.widthAnchor.constraint(equalToConstant: Constants.searchBarHeight)
        ].forEach { $0.isActive = true }

        [searchTermLabel.topAnchor.constraint(equalTo: clearSearchButton.bottomAnchor, constant: Constants.searchBarPadding),
         searchTermLabel.rightAnchor.constraint(equalTo: clearSearchButton.rightAnchor)
        ].forEach { $0.isActive = true }

        viewModel.searchTerm
            .map { searchTerm -> String? in
                guard let searchTerm = searchTerm else { return nil }
                return """
                \(Constants.searchTermPrefix)
                \(searchTerm)
                """
            }
            .drive(searchTermLabel.rx.text)
            .disposed(by: trashBag)

        let validSearchTerm = viewModel.searchTerm
            .map { $0 != nil && $0?.isEmpty == false }

        let isSearching = searchBar.viewModel.currentStatusDriver
            .map { $0 == .active }

        Driver.combineLatest(validSearchTerm, isSearching)
            .map { isValid, isSearching -> Bool in
                guard !isSearching else { return true }
                return !isValid
            }
            .drive(onNext: { [unowned self] shouldHide in
                let alpha: CGFloat = shouldHide ? 0 : 1
                UIView.animate(withDuration: 0.3) {
                    self.clearSearchButton.alpha = alpha
                }
            }).disposed(by: trashBag)

        clearSearchButton.rx.tap
            .bind(onNext: searchBar.clear)
            .disposed(by: trashBag)
    }

    private func setupKeyboardObserver() {
        let takeUntilObserver = rx.methodInvoked(#selector(viewWillDisappear))
        _ = Keyboard.shared.currentStatus.asObservable()
            .takeUntil(takeUntilObserver)
            .map { $0.isShowing }
            .subscribe(onNext: {[unowned self] isKeyboardActive in
                if isKeyboardActive {
                    self.collectionView.refreshControl = nil
                } else {
                    self.collectionView.refreshControl = self.refreshControl
                }
            })
        searchBar.viewModel.setupKeyboardObserver(takeUntilObserver: takeUntilObserver)
    }

    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        [activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ].forEach { $0.isActive = true }
    }

    private func setupBlurView() {
        blurView.alpha = 0.0
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        [blurView.topAnchor.constraint(equalTo: view.topAnchor),
         blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
         blurView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }
    }

    private func setupDownloadingView() {
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

    private func setupViewModel() {
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

        viewModel.configure(with: searchBar.viewModel)
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
        setupBlurView()
        setupPermissionView()
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1.0
            self.photoPermissionView.alpha = 1.0
        }
    }

    func showDownloadingView(with requestState: RequestState) {
        guard case let .downloading(picutre) = requestState else { return }
        downloadingView.configure(with: viewModel.requestState.asObservable(), picture: picutre)

        setupBlurView()
        setupDownloadingView()
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1.0
            self.downloadingView.alpha = 1.0
        }
    }

    @objc func performPullToRefresh() {
        loadWall(requestType: .pullToRefresh)
    }

    private func loadWall(requestType: WallRequestType) {
        viewModel.requstWallPaperData(requestType: requestType)
    }

    // MARK: DownloadingViewDelegate

    func closeDownloadView() {
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.blurView.alpha = 0.0
            self.downloadingView.alpha = 0.0
        }, completion: { _ in
            self.blurView.removeFromSuperview()
            self.downloadingView.removeFromSuperview()
        })
    }

    // MARK: PhotoPermissionViewDelegate

    func closePhotoPermissionView() {
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.blurView.alpha = 0.0
            self.photoPermissionView.alpha = 0.0
        }, completion: { _ in
            self.blurView.removeFromSuperview()
            self.photoPermissionView.removeFromSuperview()
        })
    }
}
