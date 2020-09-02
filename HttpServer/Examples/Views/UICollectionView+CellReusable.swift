//
//  UICollectionView+CellReusable.swift
//  YouZhiYuan
//
//  Created by youzy01 on 2019/12/27.
//  Copyright © 2019 泽i. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCell<C: UICollectionViewCell>(_ cell: C.Type) where C: CellConfigurable {
        if let nib = C.nib {
            register(nib, forCellWithReuseIdentifier: C.reuseableIdentifier)
        } else {
            register(cell, forCellWithReuseIdentifier: C.reuseableIdentifier)
        }
    }

    func dequeReusableCell<C: UICollectionViewCell>(indexPath: IndexPath) -> C where C: CellConfigurable {
        return dequeueReusableCell(withReuseIdentifier: C.reuseableIdentifier, for: indexPath) as! C
    }

    func registerHeaderView<C: UICollectionReusableView>(_ reusableView: C.Type) where C: CellConfigurable {
        if let nib = C.nib {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: C.reuseableIdentifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: C.reuseableIdentifier)
        }
    }

    func dequeReusableHeaderView<C: UICollectionReusableView>(indexPath: IndexPath) -> C where C: CellConfigurable {
        let header = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: C.reuseableIdentifier, for: indexPath) as! C
        return header
    }

    func registerFooterView<C: UICollectionReusableView>(_ reusableView: C.Type) where C: CellConfigurable {
        if let nib = C.nib {
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: C.reuseableIdentifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: C.reuseableIdentifier)
        }
    }

    func dequeReusableFooterView<C: UICollectionReusableView>(indexPath: IndexPath) -> C where C: CellConfigurable {
        let footer = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: C.reuseableIdentifier, for: indexPath) as! C
        return footer
    }
}
