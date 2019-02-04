//
//  ArrayExtension.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

extension Array {
    mutating func remove(at indexes: [IndexPath]) {
        var lastIndex: IndexPath? = nil
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index.row)
            lastIndex = index
        }
    }
}
