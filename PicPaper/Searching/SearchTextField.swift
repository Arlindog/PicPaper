//
//  SearchTextField.swift
//  PicPaper
//
//  Created by Arlindo on 2/24/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {
    private struct Constants {
        static let defaultInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    private let padding: UIEdgeInsets

    init(padding: UIEdgeInsets = Constants.defaultInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        padding = Constants.defaultInsets
        super.init(coder: aDecoder)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
