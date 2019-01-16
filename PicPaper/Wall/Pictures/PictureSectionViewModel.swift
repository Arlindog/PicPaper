//
//  PictureSectionViewModel.swift
//  PicPaper
//
//  Created by Arlindo on 8/26/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import IGListKit

class PictureSectionViewModel: NSObject, SectionViewModel {

    private struct Constants {
        static let aspectRatio: CGFloat = 9/16
        static let maxPictureHeight: CGFloat = 200
        static let pictureCellToolbarHeight: CGFloat = 60
    }

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

    /// Opens Actionsheet to allow user to open either the user's profile
    /// or the full image in Pixabay
    func openMoreInfo() {

    }
}
