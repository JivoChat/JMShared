//
//  UITableViewExtensions.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 10/01/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public extension UICollectionView {
    public var canScroll: Bool {
        guard let _ = dataSource else { return false }
        return true
    }
}

public extension UITableView {
    public var canScroll: Bool {
        guard let _ = dataSource else { return false }
        return true
    }
}
