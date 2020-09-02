//
//  CellReusable.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

/// Cell快速注册，获取协议
protocol CellReusable: class {
    static var reuseableIdentifier: String {get}
    static var nib: UINib? {get}
}

extension CellReusable where Self: UITableViewCell {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return nil
    }
}

extension CellReusable where Self: UITableViewHeaderFooterView {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return nil
    }
}

extension CellReusable where Self: UICollectionViewCell {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return nil
    }
}

extension CellReusable where Self: UICollectionReusableView {
    static var reuseableIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return nil
    }
}

/// Cell配置数据协议
protocol CellConfigurable: CellReusable {
    associatedtype T
    func configure(_ item: T)
}
