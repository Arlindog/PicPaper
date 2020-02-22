//
//  Array+Extensions.swift
//  PicPaper
//
//  Created by Arlindo on 2/22/20.
//  Copyright © 2020 DevByArlindo. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safely index: Int) -> Element? {
        guard 0 <= index && index < count else { return nil }
        return self[index]
    }
}
