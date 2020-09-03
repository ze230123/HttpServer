//
//  CollegeDetailsViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/2.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

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
        button.isSelected = college.isLike(id)
    }

    @IBAction func likeAction(_ sender: UIButton) {
        view.showLoading(.normalHud)
        Server.likeCollege(
            id: id,
            name: name,
            isLike: sender.isSelected,
            observer: StringObserver(
                disposeBag: disposeBag,
                handler: { (result) in
                    self.view.stopLoading()
                    switch result {
                    case .success:
                        sender.isSelected = !sender.isSelected
                    case .failure(let error):
                        print(error, error.localizedDescription)
                        MBHUD.showMessage(error.localizedDescription, to: self.view)
                }
            })
        )
    }
}
