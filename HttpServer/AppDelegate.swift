//
//  AppDelegate.swift
//  HttpServer
//
//  Created by youzy01 on 2020/6/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("App Launching")
        HttpServer.shared.initServer()
        return true
    }
//    var mapManager: BMKMapManager?
//
//    func initBaiDuMap() {
//        // 初始化定位SDK
//        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: "Bl0GqzMSGnVT7n5ZGiG93waph6LQ0IhM", authDelegate: self)
//
//        //要使用百度地图，请先启动BMKMapManager
//        mapManager = BMKMapManager()
//        /**
//         百度地图SDK所有API均支持百度坐标（BD09）和国测局坐标（GCJ02），用此方法设置您使用的坐标类型.
//         默认是BD09（BMK_COORDTYPE_BD09LL）坐标.
//         如果需要使用GCJ02坐标，需要设置CoordinateType为：BMK_COORDTYPE_COMMON.
//         */
//        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORD_TYPE.COORDTYPE_BD09LL) {
//            NSLog("经纬度类型设置成功")
//        } else {
//            NSLog("经纬度类型设置失败")
//        }
//
//        //启动引擎并设置AK并设置delegate
//        if !(mapManager!.start("Bl0GqzMSGnVT7n5ZGiG93waph6LQ0IhM", generalDelegate: self)) {
//            NSLog("启动引擎失败")
//        }
//    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate: BMKLocationAuthDelegate {
    
}
