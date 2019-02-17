//
//  UIView+Rx.swift
//  PicPaper
//
//  Created by Arlindo on 2/17/19.
//  Copyright © 2019 DevByArlindo. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIView {

    public var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.backgroundColor = color
        }
    }
}
