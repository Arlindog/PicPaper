//
//  UITextField+Rx.swift
//  PicPaper
//
//  Created by Arlindo on 2/24/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    public var attributedPlaceholder: Binder<NSAttributedString?> {
        return Binder(self.base) { textField, attributedPlaceholder in
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
}
