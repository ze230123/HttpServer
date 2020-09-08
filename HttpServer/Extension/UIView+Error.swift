//
//  UIView+Error.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

/// 加载动画视图协议
protocol LoadAnimateable where Self: UIView {
    func start()
    func stop()
}

/// 空视图协议
protocol ViewEmptyable where Self: UIView {
    func updateTitle(_ title: String)
    func updateContent(_ content: String)
}

/// 错误提示视图协议
protocol ViewErrorable where Self: UIView {
    func update(_ error: APIError, observer: ErrorHandlerObserverType?)
}

/// 错误处理回调
protocol ErrorHandlerObserverType where Self: BaseViewController {
    /// 重试
    func onReTry()
}

private struct Keys {
    static var empty = "empty"
    static var error = "error"
    static var loading = "loading"
    static var imageHud = "imageHud"
}

extension UIView {
    enum LoadingStyle {
        /// 图片动画(全屏)
        case image
        /// 图片动画(缩略图)
        case imageHud
        /// 默认菊花
        case normalHud

        static func random() -> LoadingStyle {
            let arr: [LoadingStyle] = [.image, .imageHud, .normalHud]
            return arr.randomElement()!
        }
    }

    enum ErrorStyle {
        case view
        case hud
    }
}
// MARK: - 私有存储，runtime添加
extension UIView {
    /// 错误提示View
    private var _errorView: ViewErrorable? {
        set {
            objc_setAssociatedObject(self, &Keys.error, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.error) as? ViewErrorable
        }
    }

    /// 无数据页面提示View
    private var _emptyView: ViewEmptyable? {
        set {
            objc_setAssociatedObject(self, &Keys.empty, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.empty) as? ViewEmptyable
        }
    }

    /// 加载动画View
    private var _imageLoadingView: LoadAnimateable? {
        set {
            objc_setAssociatedObject(self, &Keys.loading, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.loading) as? LoadAnimateable
        }
    }

    /// 加载hud动画
    private var _imageHudLoadingView: MBHUD? {
        set {
            objc_setAssociatedObject(self, &Keys.imageHud, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.imageHud) as? MBHUD
        }
    }
}
// MARK: - 只读
extension UIView {
    /// 错误提示view
    var errorView: ViewErrorable? {
        if _errorView == nil {
            _errorView = ErrorView()
            _errorView?.frame = bounds
            _errorView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        return _errorView
    }

    /// 无数据提示view
    var emptyView: ViewEmptyable? {
        if _emptyView == nil {
            _emptyView = EmptyView()
            _emptyView?.frame = bounds
            _emptyView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        return _emptyView
    }

    /// 全屏加载动画view
    var imageLoadingView: LoadAnimateable? {
        if _imageLoadingView == nil {
            _imageLoadingView = LoadingView()
            _imageLoadingView?.frame = bounds
            _imageLoadingView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        return _imageLoadingView
    }

    /// 小屏加载动画view
    var imageHudLoadingView: MBHUD? {
        if _imageHudLoadingView == nil {
            _imageHudLoadingView = MBHUD.loading(to: self)
        }
        return _imageHudLoadingView
    }
}
// MARK: - 更新视图 function
extension UIView {
    /// 更新错误提示view
    /// - Parameter errorView: 错误提示view
    func update(_ errorView: ViewErrorable) {
        _errorView = errorView
    }

    /// 更新无数据提示view
    /// - Parameter emptyView: 无数据提示view
    func update(_ emptyView: ViewEmptyable) {
        _emptyView = emptyView
    }

    /// 更新空视图标题
    ///
    /// 在`viewDidLoad()`方法中调用
    ///
    /// - Parameter title: 标题
    func updateEmptyTitle(_ title: String) {
        emptyView?.updateTitle(title)
    }

    /// 更新空视图内容
    ///
    /// 在`viewDidLoad()`方法中调用
    ///
    /// - Parameter content: 内容
    func updateEmptyContent(_ content: String) {
        emptyView?.updateContent(content)
    }
}

// MARK: - Reset
private extension UIView {
    /// 重置视图
    func reset() {
        if _errorView != nil {
            errorView?.removeFromSuperview()
        }
        if _emptyView != nil {
            emptyView?.removeFromSuperview()
        }
        if _imageLoadingView != nil {
            imageLoadingView?.stop()
            imageLoadingView?.removeFromSuperview()
        }
        MBHUD.hide(for: self, animated: true)
    }
}
// MARK: - Error
extension UIView {
    /// 显示错误提示
    /// - Parameter error: 错误
    func showError(_ error: APIError, style: ErrorStyle, observer: ErrorHandlerObserverType? = nil) {
        reset()
        switch style {
        case .view:
            guard let errorView = errorView else { return }
            addSubview(errorView)
            errorView.update(error, observer: observer)
        case .hud:
            MBHUD.showMessage(error.localizedDescription, to: self, delay: 3)
        }
    }
}
// MARK: - Empty
extension UIView {
    /// 显示空数据提示
    /// - Parameter isEmpty: 是否为空
    func showEmpty(_ isEmpty: Bool) {
        reset()
        guard isEmpty, let empty = emptyView else { return }
        addSubview(empty)
    }
}
// MARK: - Loading
extension UIView {
    /// 显示加载动画
    /// - Parameters:
    ///   - style: 动画类型
    ///   - isEnabled: 是否启用
    func showLoading(_ style: LoadingStyle, isEnabled: Bool = true) {
        reset()
        guard isEnabled else { return }
        switch style {
        case .image:
            showImageLoadingView()
        case .imageHud:
            showImageHudLoadingView()
        case .normalHud:
            showNormalHud()
        }
    }

    /// 停止加载动画
    func stopLoading() {
        reset()
    }

    private func showImageLoadingView() {
        guard let loadingView = imageLoadingView else { return }
        loadingView.start()
        addSubview(loadingView)
    }

    private func showImageHudLoadingView() {
        guard let hud = imageHudLoadingView else { return }
        addSubview(hud)
        hud.show(animated: true)
    }

    private func showNormalHud() {
        _ = MBHUD.showCustomAdded(to: self, animated: true)
    }
}
