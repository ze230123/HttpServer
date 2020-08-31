//
//  RxCache.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/10.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import Security
import RxSwift
import Moya

/// Rx封装的缓存工具类
class RxCache {
    func load(_ key: String) -> Observable<String?> {
        return Observable.just(CacheCore.shared.cache(for: key))
    }

    func save(_ value: String, key: String, expiry: Expiry) -> Observable<String> {
        CacheCore.shared.setCache(value, key: key, expiry: expiry)
        return Observable.just(value)
    }
}

/// 缓存策略基类
class BaseStrategy {
    fileprivate let config: CacheConfig

    init(config: CacheConfig) {
        self.config = config
    }

    /// 读取缓存数据
    ///
    /// 先在磁盘中查找缓存，如果没有找到则发送`HttpError.noCache`错误
    /// 如果`needEmpty`为true，则监听`catchError`返回`Observable.empty()`
    ///
    /// - Parameters:
    ///   - rxCache: 缓存工具类
    ///   - needEmpty: Bool类型，true：没找到缓存时返回Empty，false：正常返回
    /// - Returns: Observable<String>类型的可观察对象
    func loadCache(_ rxCache: RxCache, needEmpty: Bool) -> Observable<String> {
        print("加载缓存")
        var observable = rxCache.load(config.api + config.parameter).map { (value) -> String in
            guard let new = value else {
                throw HttpError.noCache
            }
            return new
        }
        if needEmpty {
            observable = observable.catchError({ (_) -> Observable<String> in
                return Observable.empty()
            })
        }
        return observable
    }

    func loadRemote(_ rxCache: RxCache, observable: Observable<Response>) -> Observable<String> {
        print("加载远程")
        let key = config.key
        let expiry = config.expiry

        let obser = observable.flatMap { (response) -> Observable<String> in
            let result = try response.mapResultValue()
            return rxCache.save(result, key: key, expiry: expiry)
        }
        return obser
    }

    /// 执行操作
    /// - Parameters:
    ///   - rxCache: 缓存工具
    ///   - handler: 接口请求频率处理工具
    ///   - observable: 正常的请求
    /// - Returns: 返回经过缓存策略工具处理过的请求
    func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        fatalError()
    }
}

class NoCacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return Observable.error(HttpError.frequently)
        } else {
            return observable.map { (response) -> String in
                return try response.mapResultValue()
            }
        }
    }
}

/// 缓存策略：缓存、网络都会返回
///
/// 先读取缓存，不管有没有缓存都会请求网络
/// 等网络返回后，发现数据一样就不会返回，不同则会再次返回网络的数据
class CacheAndRemoteDistinctStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return Observable.concat(cache, remote).filter( { !$0.isEmpty } ).distinctUntilChanged(==)
        }
    }
}

/// 缓存策略：缓存优先
///
/// 先读取缓存，缓存不存在，在请求网络
/// 如果次数超出规定限制，直接读取缓存
class FirstCacheStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.path, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return cache.ifEmpty(switchTo: remote)
        }
    }
}

/// 缓存策略：网络优先
///
/// 先请求网络，网络请求失败，再加载缓存
/// 如果次数超出规定限制 直接读取缓存
class FirstRequestStrategy: BaseStrategy {
    override func execute(_ rxCache: RxCache, handler: RequestFrequencyHandler, observable: Observable<Response>) -> Observable<String> {
        if handler.invalid(api: config.api, parameter: config.parameter) {
            return loadCache(rxCache, needEmpty: false)
        } else {
            let cache = loadCache(rxCache, needEmpty: true)
            let remote = loadRemote(rxCache, observable: observable)
            return remote.catchError( { _ in cache } )
        }
    }
}

extension Response {
    /// 取出返回数据中的`result`，在将其转换为string返回
    /// `result`如果是String，直接返回`result`
    func mapResultValue() throws -> String {
        guard let json = try mapJSON() as? [String: Any],
         let result = json["result"] else {
            throw MoyaError.stringMapping(self)
        }
        guard JSONSerialization.isValidJSONObject(result) else {
            if let data = result as? String {
                return data
            }
            throw MoyaError.jsonMapping(self)
        }
        let data = try JSONSerialization.data(withJSONObject: result, options: [])
        return String(data: data, encoding: .utf8) ?? ""
    }
}

fileprivate var errorViews: [Int: UIView] = [:]
fileprivate var emptyViews: [Int: UIView] = [:]
fileprivate var loadingViews: [Int: UIView] = [:]

fileprivate struct Keys {
    static var empty = "empty"
    static var error = "error"
    static var loading = "loading"
    static var imageHud = "imageHud"
}

extension UIView {
    /// 错误提示View
    private var errorView: UIView? {
        set {
            objc_setAssociatedObject(self, &Keys.error, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.error) as? UIView
        }
    }

    /// 无数据页面提示View
    private var emptyView: UIView? {
        set {
            objc_setAssociatedObject(self, &Keys.empty, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.empty) as? UIView
        }
    }

    /// 加载动画View
    private var imageLoadingView: LoadAnimateable? {
        set {
            objc_setAssociatedObject(self, &Keys.loading, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.loading) as? LoadAnimateable
        }
    }

    /// 加载hud动画
    private var imageHudLoadingView: MBHUD? {
        set {
            objc_setAssociatedObject(self, &Keys.imageHud, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Keys.imageHud) as? MBHUD
        }
    }

    func showError(_ error: HttpError) {
        reset()
    }

    func showEmpty(_ isEmpty: Bool) {
        reset()

        guard isEmpty else { return }

        func addEmptyView(_ emptyView: UIView) {
            emptyView.frame = bounds
            emptyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(emptyView)
        }

        if let empty = emptyView {
            addEmptyView(empty)
        } else {
            let view = EmptyView()
            addEmptyView(view)
            emptyView = view
        }
    }

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

    func stopLoading() {
        reset()
    }

    private func showImageLoadingView() {
        func addLoadingView(_ loadingView: LoadAnimateable) {
            loadingView.frame = bounds
            loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(loadingView)
        }

        if let loadingView = imageLoadingView {
            addLoadingView(loadingView)
        } else {
            let view = LoadingView()
            view.start()
            addLoadingView(view)
            imageLoadingView = view
        }
    }

    private func showImageHudLoadingView() {
        if let hud = imageHudLoadingView {
            addSubview(hud)
            hud.show(animated: true)
        } else {
            imageHudLoadingView = MBHUD.showLoading(to: self)
        }
    }

    private func showNormalHud() {
        _ = MBHUD.showCustomAdded(to: self, animated: true)
    }

    fileprivate func reset() {
        errorView?.removeFromSuperview()
        emptyView?.removeFromSuperview()
        imageLoadingView?.removeFromSuperview()
        MBHUD.hide(for: self, animated: true)
    }
}

import MJRefresh

extension UITableView {
    func addRefreshHeader(target: Any, action: Selector) {
        mj_header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
    }

    func addRefreshFooter(target: Any, action: Selector) {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        footer.isHidden = true
        mj_footer = footer
    }

    func endRefresh(_ action: RefreshAction, isNotData: Bool) {
        switch action {
        case .load:
            endRefreshHeader(isNotData: isNotData)
        case .more:
            endRefreshFooter(isNotData: isNotData)
        }
    }

    private func endRefreshHeader(isNotData: Bool) {
        mj_header?.endRefreshing()
        if !isNotData && mj_footer != nil {
            mj_footer?.isHidden = false
            mj_footer?.resetNoMoreData()
        } else if mj_footer != nil {
            mj_footer?.isHidden = true
        }
    }

    private func endRefreshFooter(isNotData: Bool) {
        if isNotData {
            mj_footer?.endRefreshingWithNoMoreData()
        } else {
            mj_footer?.endRefreshing()
        }
    }

    /// 重新加载数据并检查数据是否为空
    func reloadDataAndCheckEmpty(type: CheckType = .row) {
        reloadData()
        let isEmpty = isEmptyData(type: type)
        print(isEmpty)
        superview?.reset()
        showEmpty(isEmpty)
    }

    private func isEmptyData(type: CheckType) -> Bool {
        switch type {
        case .section:
            return numberOfSections == 0
        case .row:
            return numberOfSections == 1 && numberOfRows(inSection: 0) == 0
        }
    }

    enum CheckType {
        case section
        case row
    }
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
}

class EmptyView: UIView {
    lazy var label = UILabel()

    deinit {
        print("EmptyView_deinit")
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyView {
    func setup() {
        backgroundColor = .orange

        label.text = "没有数据"
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

protocol LoadAnimateable where Self: UIView {
    func start()
    func stop()
}

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
