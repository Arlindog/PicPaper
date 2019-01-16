//
//  PictureCell.swift
//  PicPaper
//
//  Created by Arlindo on 8/26/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class PictureCell: UICollectionViewCell {

    static let defaultIdentifier: String = String(describing: PictureCell.self)

    private struct Constants {
        static let userImageViewSizeDimension: CGFloat = 45
    }

    private var trashBag = DisposeBag()

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        trashBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = Constants.userImageViewSizeDimension / 2
    }

    func configure(with viewModel: PictureSectionViewModel) {
        pictureImageView.sd_cancelCurrentAnimationImagesLoad()
        activityIndicator.startAnimating()

        pictureImageView.sd_setImage(with: URL(string: viewModel.picture.imageUrl)) { [weak self] (_, error, _, _) in
            self?.activityIndicator.stopAnimating()
            if let error = error {
                print("Error Loading Image at \(viewModel.picture.imageUrl): \(error)")
                self?.pictureImageView.image = #imageLiteral(resourceName: "error_view")
            }
        }

        userImageView.sd_cancelCurrentAnimationImagesLoad()
        userImageView.sd_setImage(with: URL(string: viewModel.picture.userImageUrl)) { [weak self] (_, error, _, _) in
            if let error = error {
                print("Error Loading User Image at \(viewModel.picture.userImageUrl): \(error)")
                self?.userImageView.image = #imageLiteral(resourceName: "profile").withRenderingMode(.alwaysTemplate)
            }
        }

        usernameLabel.text = viewModel.picture.username

        moreInfoButton.rx.tap
            .subscribe(onNext: {
                viewModel.openMoreInfo()
            }).disposed(by: trashBag)
    }
}
