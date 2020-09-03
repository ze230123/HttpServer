# Uncomment the next line to define a global platform for your project
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '10.0'

target 'HttpServer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HttpServer
  pod 'Moya/RxSwift'
  pod 'ObjectMapper'
  pod 'GRDB.swift/SQLCipher'
  pod 'KeychainSwift', '~> 19.0'
  pod 'BMKLocationKit'
  pod 'MJRefresh'
  pod 'MBProgressHUD'
  pod 'SnapKit'
  pod 'SDWebImage'
  pod 'SwiftyUserDefaults'

  pod 'LookinServer', :configurations => ['Debug']

  target 'HttpServerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HttpServerUITests' do
  	inherit! :search_paths
    # Pods for testing
  end

end
