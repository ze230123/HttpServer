//
//  ZipUploadViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell, CellConfigurable {
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 8
    }

    static var nib: UINib? {
        return UINib(nibName: reuseableIdentifier, bundle: nil)
    }

    func configure(_ item: UIImage) {
        imageView.image = item
    }
}

class ZipUploadViewController: BaseCollectionViewController {
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    private var dataSource: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ZipUploadViewController {
    @IBAction func imageAction() {
        showImagePickerController()
    }

    @IBAction func uploadAction() {
        ImageServer.upload(images: dataSource, observer: ListObserver<String>(disposeBag: disposeBag, observer: self))
    }
}

extension ZipUploadViewController: ObserverHandler {
    typealias Element = [String]

    func resultHandler(_ result: Result<[String], APIError>) {
        switch result {
        case .success(let list):
            print(list)
        case .failure(let error):
            print(error)
        }
    }
}

private extension ZipUploadViewController {
    func showImagePickerController() {
        let imageController = UIImagePickerController()
        imageController.sourceType = .photoLibrary
        imageController.delegate = self
        present(imageController, animated: true, completion: nil)
    }
}

extension ZipUploadViewController: UINavigationControllerDelegate {
}

extension ZipUploadViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            dataSource.append(pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ZipUploadViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeReusableCell(indexPath: indexPath) as ImageCollectionCell
        cell.configure(dataSource[indexPath.item])
        return cell
    }
}
