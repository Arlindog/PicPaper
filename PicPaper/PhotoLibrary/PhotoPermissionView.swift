//
//  PhotoPermissionView.swift
//  PicPaper
//
//  Created by Arlindo on 2/16/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift

protocol PhotoPermissionViewDelegate: class {
    func closePhotoPermissionView()
}

class PhotoPermissionView: UIView, PhotoPermissionViewModelDelegate {
    private struct Constants {
        static let closeButtonSizeDimension: CGFloat = 30
        static let permissionButtonHeight: CGFloat = 50
    }
    private let trashBag = DisposeBag()
    private let viewModel = PhotoPermissionViewModel()
    weak var delegate: PhotoPermissionViewDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var permissionButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var permissionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        loadFromNib()
        viewModel.delegate = self
        setupBindings()

        clipsToBounds = true
        layer.cornerRadius = 5
        closeButton.layer.cornerRadius = Constants.closeButtonSizeDimension / 2
        permissionButton.layer.cornerRadius = Constants.permissionButtonHeight / 2

        imageView.image = #imageLiteral(resourceName: "photo-library").withRenderingMode(.alwaysTemplate)
    }

    private func setupBindings() {
        viewModel.permissionTitle
            .drive(permissionLabel.rx.text)
            .disposed(by: trashBag)

        viewModel.permissionPrompt
            .drive(permissionButton.rx.title())
            .disposed(by: trashBag)

        viewModel.permissionColor
            .drive(permissionButton.rx.backgroundColor)
            .disposed(by: trashBag)

        viewModel.permissionColor
            .drive(closeButton.rx.backgroundColor)
            .disposed(by: trashBag)

        viewModel.isAuthorized
            .filter { $0 }
            .drive(onNext: { [unowned self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.close()
                }
            }).disposed(by: trashBag)
    }

    @IBAction func close() {
        delegate?.closePhotoPermissionView()
    }

    @IBAction func permissionButtonPressed() {
        viewModel.promptPressed()
    }

    // MARK: PhotoPermissionViewModelDelegate

    func closePermission() {
        close()
    }
}
