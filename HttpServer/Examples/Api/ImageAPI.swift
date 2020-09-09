//
//  ImageAPI.swift
//  HttpServer
//
//  Created by youzy01 on 2020/9/9.
//  Copyright © 2020 youzy. All rights reserved.
//

import Moya

enum UploadApi {
    case image(Data, fileName: String)
}

extension UploadApi: TargetType {
    var task: Task {
        switch self {
        case let .image(data, _):
            return .requestData(data)
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .image(data, fileName):
            let contentType = "image/jpeg"
            let date = Formatter.string(by: "yyyyMMddHHmmss")
            let authorization = UFile.authroization(fileName, date: date, contentType: contentType)
            return [
                "Authorization": authorization,
                "Content-Length": data.count.stringValue,
                "Content-Type": contentType,
                "Date": date
            ]
        }
    }

    var method: Method {
        return .put
    }

    var path: String {
        switch self {
        case let .image(_, fileName):
            return fileName
        }
    }

    var baseURL: URL {
        return URL(string: "http://toc.cn-bj.ufileos.com/")!
    }
}

private let dateFormatter = DateFormatter()

private struct Formatter {
    static func string(by format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
}

struct UFile {
    private static let publicKey = "TOKEN_cf8aefab-828f-4604-a2c7-b4adb8ed5946"
    private static let privateKey = "381ecfdc-955c-431c-ab35-8ba8de83b4d9"

    static func authroization(_ fileName: String, date: String, contentType: String) -> String {
        let key = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var sign = ""
        sign.append("PUT" + "\n")
        sign.append("" + "\n")
        sign.append(contentType + "\n")
        sign.append(date + "\n")
        sign.append("/" + "toc")
        sign.append("/" + key)
        let signature = sign.hmacSHA1(key: privateKey)
        var result = ""
        result += "UCloud "
        result += publicKey
        result += ":"
        result += signature
        return result
    }
}

import CommonCrypto

private extension String {
    func hmacSHA1(key: String) -> String {
        let cKey = key.cString(using: .ascii)
        let cData = self.cString(using: .utf8)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), cKey!, strlen(cKey!), cData!, strlen(cData!), result)
        let data = Data(bytes: result, count: Int(CC_SHA1_DIGEST_LENGTH))
        let value = data.base64EncodedString(options: .lineLength64Characters)
        return value
    }
}

import RxSwift

private var plugins: [PluginType] = [LoggerPlugin()]
private let provider = MoyaProvider<MultiTarget>(requestClosure: timeoutRequestClosure ,plugins: plugins)

struct ImageServer {
    static private func request(api: TargetType) -> Observable<Response> {
        return provider
            .rx
            .request(MultiTarget(api))
            .asObservable()
            .filter(statusCode: 200)
    }

    static func upload(image: Image, name: String) -> Observable<String> {
        let data = ImageHelper.compression(image: image)
        let fileName = name + ".jpeg"
        return request(api: UploadApi.image(data, fileName: fileName)).map { (response) -> String in
            return response.request?.url?.absoluteString ?? ""
        }
    }

    static func upload(image: Image, observer: VoidObserver) {
        upload(image: image, name: "nameimage").subscribe(observer).disposed(by: observer.disposeBag)
    }

    static func upload(images: [Image], observer: ListObserver<String>) {
        let requests = images.enumerated().map { upload(image: $0.element, name: UFile.name(from: $0.offset)) }
        Observable.zip(requests).subscribe(observer).disposed(by: observer.disposeBag)
    }
}

extension UFile {
    static func name(from element: Int) -> String {
        return Formatter.string(by: "yyyyMMddHHmmss") + "\(element)"
    }
}

struct ImageHelper {
    static func imageSize(for size: CGSize) -> CGSize {
        var width = size.width
        var height = size.height
        
        let boundary: CGFloat = 1280

        // width, height <= 1280, Size remains the same
        guard width > boundary || height > boundary else {
            return CGSize(width: width, height: height)
        }

        // aspect ratio
        let s = max(width, height) / min(width, height)
        if s <= 2 {
            // Set the larger value to the boundary, the smaller the value of the compression
            let x = max(width, height) / boundary
            if width > height {
                width = boundary
                height = height / x
            } else {
                height = boundary
                width = width / x
            }
        } else {
            // width, height > 1280
            if min(width, height) >= boundary {
//                boundary = type == .session ? 800 : 1280
                // Set the smaller value to the boundary, and the larger value is compressed
                let x = min(width, height) / boundary
                if width < height {
                    width = boundary
                    height = height / x
                } else {
                    height = boundary
                    width = width / x
                }
            }
        }
        return CGSize(width: width, height: height)
    }

    static func compression(image: UIImage) -> Data {
        let compressSize = imageSize(for: image.size)

        UIGraphicsBeginImageContext(compressSize)
        image.draw(in: CGRect(origin: .zero, size: compressSize))
        let compressImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let data = compressImage?.jpegData(compressionQuality: 0.5)
        return data!
    }

    
}
