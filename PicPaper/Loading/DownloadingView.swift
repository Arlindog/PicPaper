//
//  DownloadingView.swift
//  PicPaper
//
//  Created by Arlindo on 1/20/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol DownloadingViewDelegate: class {
    func closeDownloadView()
}

class DownloadingView: UIView {
    private struct Constants {
        static let cornerRadius: CGFloat = 5
    }

    private let trashBag = DisposeBag()
    weak var delegate: DownloadingViewDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let contentView = loadFromNib()
        contentView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.cornerRadius = Constants.cornerRadius
        closeButton.layer.cornerRadius = Constants.cornerRadius
    }

    func configure(with requestState: Observable<RequestState>, picture: PixabayPicture) {
        imageView.sd_setImage(with: URL(string: picture.imageUrl), completed: nil)

        let state = requestState
            .map { $0.isDownloading }
            .share(replay: 2)

        state
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: trashBag)

        state
            .map { $0 ? "Downloading..." : "Downloaded!"}
            .bind(to: statusLabel.rx.text)
            .disposed(by: trashBag)

        state
            .map { $0 ? "Cancel" : "Close"}
            .bind(to: closeButton.rx.title())
            .disposed(by: trashBag)
    }

    @IBAction private func close() {
        delegate?.closeDownloadView()
    }
}
