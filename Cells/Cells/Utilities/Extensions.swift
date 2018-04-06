//
//  Extensions.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 19/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation
import SpriteKit

public func + (left: (Int, Int), right: (Int, Int)) -> (Int, Int) {
    return (left.0 + right.0, left.1 + right.1)
}

public func - (left: (Int, Int), right: (Int, Int)) -> (Int, Int) {
    return (left.0 - right.0, left.1 - right.1)
}
