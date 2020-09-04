//
//  MBProgressHUD+Custom.swift
//  HttpServer
//
//  Created by youzy01 on 2020/8/31.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation
import MBProgressHUD

typealias MBHUD = MBProgressHUD

extension MBProgressHUD {
    private static func updateLoadingHud(_ hud: MBProgressHUD) {
        hud.mode = .customView
        let loadview = LoadingView()
        loadview.start()
        hud.customView = loadview
        hud.label.text = "加载中..."
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.3)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.white
    }

    static func loading(to view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD(view: view)
        updateLoadingHud(hud)
        return hud
    }

    static func showLoading(to view: UIView, animated: Bool = true) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        updateLoadingHud(hud)
        return hud
    }

    static func showCustomAdded(to view: UIView, animated: Bool) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.3)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.8)
        hud.contentColor = .white
        return hud
    }

    static func showMessage(_ text: String, to view: UIView, animated: Bool = true, position: Position = .center, delay: TimeInterval = 2) {
        let hud = MBProgressHUD.showAdded(to: view, animated: animated)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.8)

        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = true
        hud.mode = .text
        hud.label.text = text
        hud.label.textColor = .white
        hud.label.numberOfLines = 0

        switch position {
        case .top:
            hud.offset = CGPoint(x: 0, y: -200)
        case .center:
            hud.offset = CGPoint(x: 0, y: 0)
        case .bottom:
            hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
        }
        hud.hide(animated: animated, afterDelay: delay)
    }

    static func showTips(_ text: String, to view: UIView) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0, alpha: 0.8)

        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = true
        hud.mode = .text
        hud.label.text = text
        hud.label.textAlignment = .left
        hud.label.textColor = .white
        hud.label.numberOfLines = 0

//        switch position {
//        case .top:
//            hud.offset = CGPoint(x: 0, y: -200)
//        case .center:
//            hud.offset = CGPoint(x: 0, y: 0)
//        case .bottom:
//            hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
//        }
        hud.hide(animated: true, afterDelay: 3)
    }
}

extension MBProgressHUD {
    enum Position {
        case top
        case center
        case bottom
    }
}
