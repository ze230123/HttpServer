//
//  AllCollegeListViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/1.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit
import SnapKit
/// 院校数组
typealias CollegeList = [CollegeListModel]

/// 全部院校回调
class AllCollegeObserver: ListObserver<CollegeListModel> {
    let map = ObjectMap<NewCollegeList>()

    func mapList() -> (NewCollegeList) throws -> [CollegeListModel] {
        return { value in
            let list = value.items.map { CollegeListModel(item: $0) }
            return list
        }
    }
}

class CollegeListCollectionCell: UICollectionViewCell, CellConfigurable {
    @IBOutlet weak var collegeView: CollegeListView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalTo(ScreenW)
        }
    }

    static var nib: UINib? {
        return UINib(nibName: reuseableIdentifier, bundle: nil)
    }

    func configure(_ item: CollegeListModel) {
        collegeView.configure(item)
    }
}

class AllCollegeListViewController: BaseCollectionViewController {
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    lazy var observer = AllCollegeObserver(disposeBag: disposeBag, observer: self)

    lazy var parameter = AllCollegeParameter()

    var dataSource: CollegeList = []

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: ScreenW, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.minimumLineSpacing = 5

        addRefreshHeader()
        addRefreshFooter()

        loadData()
    }

    override func request(action: RefreshAction) {
        super.request(action: action)
        parameter.pageIndex = pageIndex
        view.showLoading(.image, isEnabled: dataSource.isEmpty)
        Server.collegeAllList(parameter: parameter, observer: observer)
    }
}

extension AllCollegeListViewController: HttpResultHandler {
    typealias Element = CollegeList
    func resultHandler(_ result: Result<CollegeList, HttpError>) {
        view.stopLoading()
        var isNotData: Bool = false
        switch result {
        case .success(let list):
            print(list.count)
            if action == .load {
                dataSource.removeAll()
            }
            dataSource.append(contentsOf: list)
            isNotData = list.count < parameter.pageSize
            collectionView.reloadDataAndCheckEmpty()
        case .failure(let error):
            view.showError(error)
        }
        collectionView.endRefresh(action, isNotData: isNotData)
    }
}

extension AllCollegeListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeReusableCell(indexPath: indexPath) as CollegeListCollectionCell
        cell.configure(dataSource[indexPath.item])
        return cell
    }
}

extension AllCollegeListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource[indexPath.item]
//        let alert = UIAlertController(title: item.name, message: nil, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "确定", style: .default, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
        let vc = CollegeDetailsViewController(id: item.numId, name: item.name)
        navigationController?.pushViewController(vc, animated: true)
    }
}
