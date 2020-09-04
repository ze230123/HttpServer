//
//  BannerView.swift
//  From
//
//  Created by 泽i on 2017/6/30.
//  Copyright © 2017年 泽i. All rights reserved.
//

import UIKit
import SDWebImage

protocol BannerViewDelegate: class {
    func bannerView(_ bannerView: BannerView, didSelectAt index: Int)
}

class BannerView: UIView {
    weak var delegate: BannerViewDelegate?

    private var images: [String] = [] {
        didSet {
//            print(images)
            collectionView.reloadData()
        }
    }

    private var pageNumber: Int = 0 {
        didSet {
            pageControl.numberOfPages = pageNumber
        }
    }
    /// 是否隐藏PageControl
    var ishiddenPageControl = false {
        didSet {
            pageControl.isHidden = ishiddenPageControl
        }
    }

    var collectionView: UICollectionView!
    private var pageControl: UIPageControl!

    private var timeInterval: TimeInterval = 4
    private var isAutoScroll: Bool = true

    private var timer: Timer?

    private let cellID = "BannerCell"

    private var isLocation = false

    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        backgroundColor = UIColor.white

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.estimatedItemSize = CGSize(width: ScreenW, height: 200)
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: cellID)
        //        collectionView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        pageControl = UIPageControl(frame: CGRect.zero)
        pageControl.currentPage = 0
        //        pageControl.currentPageIndicatorTintColor = UIColor.red
        //        pageControl.pageIndicatorTintColor = UIColor.lightGray
        addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.heightAnchor.constraint(equalToConstant: 25).isActive = true

        pageControl.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func removeFromSuperview() {
        stopScroll()
        super.removeFromSuperview()
    }

    override func didMoveToWindow() {
//        print("didMoveToWindow")
        guard window == nil else {
            scrollToStartItem()
            beginScroll()
            return
        }
        stopScroll()
    }
}

// MARK: - 初始化
extension BannerView {
    /// frame
    convenience init(frame: CGRect, interval: TimeInterval = 4, autoScroll: Bool = true) {
        self.init(frame: frame)
        timeInterval = interval
        isAutoScroll = autoScroll
    }
    /// images
    convenience init(images: [String], interval: TimeInterval = 4, autoScroll: Bool = true) {
        self.init(frame: CGRect.zero)
        timeInterval = interval
        isAutoScroll = autoScroll
        setImages(images: images)
    }
    /// 设置数据源
    ///
    /// [1, 2, 3] -> [3, 1, 2, 3, 1]
    /// [1] -> [1]
    func setImages(images: [String], isLocation: Bool = false) {
        stopScroll()
        guard images.count > 1 else {
            isAutoScroll = false
            self.images = images
            return
        }
        self.isLocation = isLocation

        guard let last = images.last else { return }
        guard let first = images.first else { return }
        var newImages = images
        pageNumber = images.count
        newImages.insert(last, at: 0)
        newImages.append(first)
        self.images = newImages
        beginScroll()
    }
}

// MARK: - 操作
private extension BannerView {
    @objc func autoScroll() {
        let rect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let point = CGPoint(x: rect.midX, y: rect.midY)

        guard let index = collectionView.indexPathForItem(at: point)?.item else {
                return
        }
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    @objc func willResignActive() {
        guard window != nil else { return }
        stopScroll()
    }

    @objc func willEnterForeground() {
        guard window != nil else { return }
        scrollToStartItem()
        beginScroll()
    }

    func beginScroll() {
        guard isAutoScroll, timer == nil, images.count > 2 else { return }
//        print("开始滚动")
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }

    func stopScroll() {
//        print("停止滚动")
        //        guard isAutoScroll else { return }
        timer?.invalidate()
        timer = nil
    }

    func scrollToStartItem() {
        guard images.count > 2 else { return }
//        print("滚动到1item")
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension BannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension BannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
        delegate?.bannerView(self, didSelectAt: pageControl.currentPage)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isLocation {
            let image = UIImage(named: "\(images[indexPath.item]).png")
//            print(image)
            (cell as? BannerCell)?.imageView.image = image
        } else {
            (cell as? BannerCell)?.set(url: images[indexPath.item])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ceil(frame.width - 0.1), height: ceil(frame.height - 0.1))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - UIScrollViewDelegate
extension BannerView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("开始拖拽")
        stopScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
//            print("停止拖拽")
            beginScroll()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 防止数组元素为1 和 scrollView的width 等于 0 时 做错误的运算，导致异常
        guard images.count > 1, scrollView.frame.width > 0 else {
            return
        }
        let page = scrollView.contentOffset.x / scrollView.frame.width
//        print(page)
        switch page {
        case _ where page <= 0:
            collectionView.scrollToItem(at: IndexPath(item: images.count - 2, section: 0), at: .centeredHorizontally, animated: false)
            pageControl.currentPage = pageNumber
        case _ where page >= CGFloat(images.count - 1):
            collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
            pageControl.currentPage = 0
        default:
            pageControl.currentPage = Int(page) - 1
        }
    }
}

// MARK: - CELL
private class BannerCell: UICollectionViewCell {

    var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = UIColor.white
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(url: String) {
        imageView.sd_setImage(
            with: URL(string: url),
            placeholderImage: UIImage(named: "big_placeholder"),
            options: [.retryFailed],
            completed: nil
        )
    }
}
