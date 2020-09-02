//
//  UITableView+Extension.swift
//  NetWork
//
//  Created by 泽i on 2018/7/18.
//  Copyright © 2018年 泽i. All rights reserved.
//

import UIKit

extension UITableView {
    func registerCell<C: UITableViewCell>(_ cell: C.Type) where C: CellReusable {
        if let nib = C.nib {
            register(nib, forCellReuseIdentifier: C.reuseableIdentifier)
        } else {
            register(cell, forCellReuseIdentifier: C.reuseableIdentifier)
        }
    }

    func dequeReusableCell<C: UITableViewCell>(indexPath: IndexPath) -> C where C: CellReusable {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: C.reuseableIdentifier, for: indexPath) as! C
    }

    func cellForRow<C>(at indexPath: IndexPath) -> C? where C: CellConfigurable {
        return self.cellForRow(at: indexPath) as? C
    }

    func registerSection<H: UIView>(_ header: H.Type) where H: CellConfigurable {
        if let nib = header.nib {
            register(nib, forHeaderFooterViewReuseIdentifier: H.reuseableIdentifier)
        } else {
            register(header, forHeaderFooterViewReuseIdentifier: H.reuseableIdentifier)
        }
    }

    func dequeReusableHeaderFooter<H: UIView>() -> H? where H: CellConfigurable {
        return dequeueReusableHeaderFooterView(withIdentifier: H.reuseableIdentifier) as? H
    }
}
