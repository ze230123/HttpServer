import UIKit
import RxSwift

//enum RxError: Error {
//    case zero
//}
//
//extension RxError: LocalizedError {
//    var errorDescription: String? {
//        switch self {
//        case .zero:
//            return "数据为0"
//        }
//    }
//}
//
//class RXNetwork {
//    static func request(_ id: Int) -> Observable<NSNumber> {
//        let observable = Observable<NSNumber>.create { (obser) -> Disposable in
//            if id == 0 {
//                obser.onError(RxError.zero)
//            } else {
//                obser.onNext(NSNumber(value: id))
//                obser.onCompleted()
//            }
//            return Disposables.create()
//        }
//        return observable
//    }
//}
//
//// RXNetwork 验证
//RXNetwork
//    .request(1)
//    .subscribe { (event) in
//        switch event {
//        case .next(let result):
//            print("next", type(of: result), result)
//        case .error(let error):
//            print("error", error.localizedDescription)
//        case .completed:
//            print("completed")
//        }
//    }.dispose()
//
//
//class Observer<Element>: ObserverType {
//    public typealias EventHandler = (Result<Element, RxError>) -> Void
//
//    let handler: EventHandler
//
//    init(_ handler: @escaping EventHandler) {
//        self.handler = handler
//    }
//
//    func on(_ event: Event<Element>) {
//        switch event {
//        case .next(let item):
//            handler(.success(item))
//        case .error(let error):
//            handler(.failure(self.catchError(error)))
//        case .completed: break
//        }
//    }
//
//    func mapObject(_ value: NSNumber) throws -> Element {
//        fatalError()
//    }
//
//    private func catchError(_ error: Error) -> RxError {
//        return RxError.zero
//    }
//}
//
//class StringObserver: Observer<String> {
//    override func mapObject(_ value: NSNumber) throws -> String {
//        return value.stringValue
//    }
//}
//
//class DoubleObserver: Observer<Double> {
//    override func mapObject(_ value: NSNumber) throws -> Double {
//        return value.doubleValue
//    }
//}
//
//class IntObserver: Observer<Int> {
//    override func mapObject(_ value: NSNumber) throws -> Int {
//        return value.intValue
//    }
//}
//
//struct Zip {
//    var stringValue: String
//    var doubleValue: Double
//}
//
//class ZipObserver: Observer<Zip> {
//    func mapZip(_ value: (string: NSNumber, double: NSNumber)) -> Zip {
//        return Zip(stringValue: value.string.stringValue, doubleValue: value.double.doubleValue)
//    }
//}
//
//class AddObserver: Observer<String> {
//    override func mapObject(_ value: NSNumber) throws -> String {
//        return value.stringValue
//    }
//}
//
//class HttpServer {
//    static let shared = HttpServer()
//
//    func request<T>(id: Int, callback: Observer<T>) {
//        RXNetwork.request(id).map(callback.mapObject).debug().subscribe(callback).dispose()
//    }
//
//    func request(id: Int) -> Observable<NSNumber> {
//        return RXNetwork.request(id)
//    }
//}
//
//class Server {
//    static let server = HttpServer.shared
//
//    static func getStringId(_ id: Int, callback: StringObserver) {
//        server.request(id: id, callback: callback)
//    }
//
//    static func getDoubleId(_ id: Int, callback: DoubleObserver) {
//        server.request(id: id, callback: callback)
//    }
//
//    static func getZipId(_ id: Int, callback: ZipObserver) {
//        let stirngRequest = server.request(id: id)
//        let doubleRequest = server.request(id: id)
//        Observable.zip(stirngRequest, doubleRequest).map(callback.mapZip(_:)).subscribe(callback).dispose()
//    }
//
//    static func getAddId(_ id: Int, callback: AddObserver) {
//        let stringCallBack = IntObserver { (result) in
//        }
//
//        server.request(id: id, callback: stringCallBack)
//
//        server
//            .request(id: id)
//            .flatMap { (number) -> Observable<NSNumber> in
//                return server.request(id: number.intValue + 1)
//            }
//            .map(callback.mapObject)
//            .subscribe(callback)
//            .dispose()
//    }
//}
//
//Server.getStringId(1, callback: StringObserver { (result) in
//    switch result {
//    case .success(let value):
//        print("success", type(of: value), value)
//    case .failure(let error):
//        print("failure", error.localizedDescription)
//    }
//})
//
//Server.getDoubleId(2, callback: DoubleObserver({ (result) in
//    switch result {
//    case .success(let value):
//        print("success", type(of: value), value)
//    case .failure(let error):
//        print("failure", error.localizedDescription)
//    }
//}))
//
//Server.getZipId(1, callback: ZipObserver({ (result) in
//    switch result {
//    case .success(let value):
//        print("success", type(of: value), value)
//    case .failure(let error):
//        print("failure", error.localizedDescription)
//    }
//}))
//
//Server.getAddId(1, callback: AddObserver({ (result) in
//    switch result {
//    case .success(let value):
//        print("success", type(of: value), value)
//    case .failure(let error):
//        print("failure", error.localizedDescription)
//    }
//}))
//
////guard  else {
////    throw MoyaError.jsonMapping(self)
////}
//print(JSONSerialization.isValidJSONObject(""))
//
//
//let result: [[String: Any]] = []
//print(JSONSerialization.isValidJSONObject(result))

import ObjectMapper

extension Mappable {
    
}

struct Model: Mappable, Equatable {
    var a: Int = 0
    var b: Int = 0
    var c: C?
    var d: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        a   <- map["a"]
        b   <- map["b"]
        c   <- map["c"]
        d   <- map["d"]
    }

    struct C: Mappable, Equatable {
        var aaa: Int = 0
        var bbb: Int = 0
        var ccc: String = ""

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            aaa <- map["aaa"]
            bbb <- map["bbb"]
            ccc <- map["ccc"]
        }
    }
}

let parameters: [String: Any] = [
    "a": 123,
    "b": 543,
    "c": [
        "aaa": 9483,
        "bbb": 5845,
        "ccc": "fewi"
    ],
    "d": "fekwjfe"
]

let data = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
let stringValue = String(data: data!, encoding: .utf8) ?? "nil"
print("jsonString", stringValue)

let item1 = Mapper<Model>().map(JSON: parameters)
print(item1)
var item2 = Mapper<Model>().map(JSON: parameters)
print(item2)
item2?.a = 1

print("\n")
print(item1 == item2)
print("\n")

let item1String = item1?.toJSONString()
print(item1String)
let item2String = item2?.toJSONString()
print(item2String)
