//
//  ErrorView.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 10

        view.backgroundColor = .lightGray
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .orange
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return button
    }()

    private var tapHandler: (() -> Void)?

    deinit {
        print("ErrorView_deinit")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

extension ErrorView {
    func setup() {
        backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 40).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40).isActive = true

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(button)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
}

extension ErrorView {
    @objc func tapAction() {
        tapHandler?()
    }

    func update(config: ErrorConfig, handler: @escaping () -> Void) {
        imageView.image = UIImage(named: config.image)
        titleLabel.text = config.title
        contentLabel.text = config.content
        button.setTitle(config.buttonTitle, for: .normal)
        tapHandler = handler
    }
}

extension ErrorView: ViewErrorable {
    func update(_ error: APIError, observer: ErrorHandlerObserverType?) {
        let config = ErrorConfig.creat(error: error)
        update(config: config) { [weak observer] in
            observer?.onReTry()
        }
    }
}

struct ErrorConfig {
    var image: String
    var title: String
    var content: String
    var buttonTitle: String

    static func creat(error: APIError) -> ErrorConfig {
        let mode = error.mode
        switch mode {
        case .noNetwork:
            return ErrorConfig(image: "notwork", title: mode.title, content: mode.content, buttonTitle: "重试")
        case .timeout:
            return ErrorConfig(image: "notwork", title: mode.title, content: mode.content, buttonTitle: "重试")
        case .overload:
            return ErrorConfig(image: "notwork", title: mode.title, content: mode.content, buttonTitle: "重试")
        default:
            return ErrorConfig(image: "notwork", title: "出错啦", content: mode.title, buttonTitle: "重试一下哦")
        }
    }
}
