//
//  SectionCell.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        collectionView.contentOffset = .zero
        collectionView.contentInset = .zero
        contentView.addSubview(collectionView)
        [collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
         collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
         collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ].forEach { $0.isActive = true }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.contentOffset = .zero
    }
}
