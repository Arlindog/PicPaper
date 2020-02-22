//
//  PictureSectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/26/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit

protocol PictureSectionViewModelDelegate: class {
    func savePicture(_ picture: PixabayPicture)
}

class PictureSectionViewModel: SectionViewModel {

    private struct Constants {
        static let aspectRatio: CGFloat = 9/16
        static let maxPictureHeight: CGFloat = 200
        static let pictureCellToolbarHeight: CGFloat = 60
    }

    weak var delegate: PictureSectionViewModelDelegate?

    override var cellIdentifier: String {
        return PictureCell.identifier
    }

    override var identity: String {
        return "\(picture.id)"
    }

    let picture: PixabayPicture

    init(picture: PixabayPicture) {
        self.picture = picture
        super.init()
    }

    override func getSize(using contextWidth: CGFloat) -> CGSize {
        return CGSize(width: contextWidth,
                      height: max(CGFloat(picture.previewHeight), Constants.maxPictureHeight) + Constants.pictureCellToolbarHeight)
    }

    func openUserProfile() {
        guard let profileUrl = URL(string: picture.userProfileUrl) else { return }
        UIApplication.shared.open(profileUrl, options: [:], completionHandler: nil)
    }

    func saveImage() {
        delegate?.savePicture(picture)
    }
}
