//
//  UIView+Extensions.swift
//  PicPaper
//
//  Created by Arlindo on 1/20/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import UIKit

extension UIView {
    class var identifier: String {
        return String(describing: self)
    }

    @discardableResult
    func loadFromNib() -> UIView {
        let view = getNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        [view.topAnchor.constraint(equalTo: topAnchor),
         view.bottomAnchor.constraint(equalTo: bottomAnchor),
         view.leftAnchor.constraint(equalTo: leftAnchor),
         view.rightAnchor.constraint(equalTo: rightAnchor)
        ].forEach { $0.isActive = true }
        return view
    }

    func getNib<View: UIView>() -> View {
        let viewType = type(of: self)
        let name = String(describing: viewType)
        let bundle = Bundle(for: viewType)
        let nib = UINib(nibName: name, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? View else { fatalError("Could not load \nib named: \(name)") }
        return view
    }
}
