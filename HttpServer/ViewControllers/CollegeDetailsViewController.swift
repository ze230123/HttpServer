//
//  CollegeDetailsViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/2.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
/// 关注院校缓存
class College {
    private var likeList: [Int] = [] {
        didSet {
            defaults.likeCollegeList = likeList
        }
    }

    init() {
        likeList = defaults.likeCollegeList
    }

    func add(_ id: Int) {
        likeList.append(id)
    }

    func remove(_ id: Int) {
        likeList.removeAll(where: { $0 == id })
    }

    func isLike(_ id: Int) -> Bool {
        return likeList.contains(id)
    }

    func like(_ id: Int, isLike: Bool) {
        if isLike {
            add(id)
        } else {
            remove(id)
        }
    }
}

class CollegeDetailsViewController: BaseViewController {
    @IBOutlet weak var button: UIButton!

    lazy var college = College()

    private let id: Int
    private let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        super.init(nibName: "CollegeDetailsViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = name
        // 判断是否关注
        button.isSelected = college.isLike(id)
    }

    @IBAction func likeAction(_ sender: UIButton) {
        view.showLoading(.normalHud)

        Server.likeCollege(
        id: id,
        name: name,
        isLike: sender.isSelected,
        disposeBag: disposeBag) { [unowned view, college, id] (result) in
            guard let view = view else { return }
            view.stopLoading()
            switch result {
            case .success:
                // 改变按钮状态
                sender.isSelected = !sender.isSelected
                // 将院校ID添加到本地缓存，或从缓存中删除ID
                // 根据按钮isSelected状态判断是添加还是删除
                // true: 添加，false：删除
                college.like(id, isLike: sender.isSelected)
            case .failure(let error):
                view.showError(error, style: .hud)
            }
        }
    }
}
