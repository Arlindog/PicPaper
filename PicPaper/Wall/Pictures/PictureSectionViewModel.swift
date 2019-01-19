//
//  PictureSectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/26/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

protocol PictureSectionViewModelDelegate: class {
    func savePicture(_ picture: PixabayPicture)
}

class PictureSectionViewModel: NSObject, SectionViewModel {

    private struct Constants {
        static let aspectRatio: CGFloat = 9/16
        static let maxPictureHeight: CGFloat = 200
        static let pictureCellToolbarHeight: CGFloat = 60
    }

    weak var delegate: PictureSectionViewModelDelegate?
    var adapter: ListAdapter?
    var sectionController: BaseSectionController = PictureSectionController()

    let picture: PixabayPicture

    init(picture: PixabayPicture) {
        self.picture = picture
        super.init()
    }

    func getSize(using contextSize: CGSize) -> CGSize {
        return CGSize(width: contextSize.width,
                      height: max(CGFloat(picture.previewHeight), Constants.maxPictureHeight) + Constants.pictureCellToolbarHeight)
    }

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }

    func openUserProfile() {
        guard let profileUrl = URL(string: picture.userProfileUrl) else { return }
        UIApplication.shared.open(profileUrl, options: [:], completionHandler: nil)
    }

    func saveImage() {
        delegate?.savePicture(picture)
    }
}
