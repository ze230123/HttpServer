//
//  UploadViewController.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class UploadViewController: BaseViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension UploadViewController {
    func upload(image: UIImage) {
        imageView.image = image

        ImageServer.upload(image: image, observer: VoidObserver(disposeBag: disposeBag, observer: { (result) in
            switch result {
            case .success(let url):
                print(url)
            case .failure(let error):
                print(error)
            }
        }))
    }
}

private extension UploadViewController {
    @IBAction func imageAction() {
        showImagePickerController()
    }
}

private extension UploadViewController {
    func showImagePickerController() {
        let imageController = UIImagePickerController()
        imageController.sourceType = .photoLibrary
        imageController.delegate = self
        present(imageController, animated: true, completion: nil)
    }
}

extension UploadViewController: UINavigationControllerDelegate {
}

extension UploadViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            upload(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
