//
//  CollegeListView.swift
//  YouZhiYuan
//
//  Created by youzy01 on 2020/7/30.
//  Copyright © 2020 泽i. All rights reserved.
//

import UIKit
import SDWebImage

/// 院校列表样式
class CollegeListView: UIView, NibLoadable {
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var proBtn: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViewFromNib()
    }

    override var intrinsicContentSize: CGSize {
        return stackView.intrinsicContentSize
    }

    func configure(_ item: CollegeListModel) {
        nameLabel.text = item.name
        proBtn.setTitle(item.provinceName,
                                for: .normal)
        iconImage.sd_setImage(with: URL(string: item.logoUrl),
                                placeholderImage: UIImage(named: "icon_benke"))
        bodyLabel.text = "\(item.classify) / \(item.belong) / \(item.type)"

        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }
}

