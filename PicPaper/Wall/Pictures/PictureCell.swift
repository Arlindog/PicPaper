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

protocol SectionCell {
    func configure(with sectionItem: SectionItem)
}

class PictureCell: UICollectionViewCell, SectionCell {
    private struct Constants {
        static let userImageViewSizeDimension: CGFloat = 45
    }

    private var trashBag = DisposeBag()

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func prepareForReuse() {
        super.prepareForReuse()
        trashBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageButton.layer.cornerRadius = Constants.userImageViewSizeDimension / 2
    }

    func configure(with sectionItem: SectionItem) {
        guard let sectionItem = sectionItem as? PictureSectionViewModel else { return }
        pictureImageView.sd_cancelCurrentAnimationImagesLoad()
        activityIndicator.startAnimating()

        pictureImageView.sd_setImage(with: URL(string: sectionItem.picture.imageUrl)) { [weak self] (_, error, _, _) in
            self?.activityIndicator.stopAnimating()
            if let error = error {
                print("Error Loading Image at \(sectionItem.picture.imageUrl): \(error)")
                self?.pictureImageView.image = #imageLiteral(resourceName: "error_view")
            }
        }

        userImageButton.sd_cancelCurrentImageLoad()
        userImageButton.sd_setImage(with: URL(string: sectionItem.picture.userImageUrl), for: .normal) { [weak self] (_, error, _, _) in
            if let error = error {
                print("Error Loading User Image at \(sectionItem.picture.userImageUrl): \(error)")
                self?.userImageButton.setImage(#imageLiteral(resourceName: "profile").withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }

        usernameLabel.text = sectionItem.picture.username

        userImageButton.rx.tap
            .subscribe(onNext: {
                sectionItem.openUserProfile()
            }).disposed(by: trashBag)

        downloadButton.rx.tap
            .subscribe(onNext: {
                sectionItem.saveImage()
            }).disposed(by: trashBag)
    }
}
