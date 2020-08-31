//
//  LoadingView.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class LoadingView: UIView, LoadAnimateable {
    lazy var indicator = UIActivityIndicatorView(style: .gray)

    deinit {
        stop()
        print("LoadingView_deinit")
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        indicator.startAnimating()
    }

    func stop() {
        indicator.stopAnimating()
    }
}

extension LoadingView {
    func setup() {
        backgroundColor = .cyan

        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
