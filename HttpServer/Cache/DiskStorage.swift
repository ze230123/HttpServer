//
//  DiskStorage.swift
//  HttpServer
//
//  Created by youzy01 on 2020/7/8.
//  Copyright © 2020 youzy. All rights reserved.
//

import Foundation

/// 磁盘配置
struct DiskConfig {
    /// 文件夹名字
    public let name: String
    ///磁盘缓存存储的最大大小（以字节为单位）
    public let maxSize: UInt
    /// 过期时间
    public let expiry: Expiry
}

/// 磁盘存储
class DiskStorage<T> {
    /// 文件管理者
    let fileManager: FileManager
    /// 配置
    let config: DiskConfig
    /// 缓存路径
    let path: String

    private let transformer: Transformer<T>

    init(config: DiskConfig, fileManager: FileManager = FileManager.default, transformer: Transformer<T>) {
        self.fileManager = fileManager
        self.config = config
        self.transformer = transformer

        let url = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        path = url?.appendingPathComponent(config.name, isDirectory: true).path ?? ""

        createDirectory()
    }
}

typealias ResourceObject = (url: Foundation.URL, resourceValues: URLResourceValues)

extension DiskStorage {
    /// 存储缓存
    @discardableResult
    func setObject(_ object: T, forKey key: String, expiry: Expiry? = nil) -> Bool {
        let newExpiry = expiry ?? config.expiry
        let filePath = makeFilePath(for: key)

        let data = transformer.toData(object)
        var isFinish = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        try? fileManager.setAttributes([.modificationDate: newExpiry.date], ofItemAtPath: filePath)
        do {
            try fileManager.setAttributes([.modificationDate: newExpiry.date], ofItemAtPath: filePath)
//            print("设置缓存时间完成", newExpiry, newExpiry.date)
        } catch let error {
            print(error.localizedDescription)
            isFinish = false
        }
//        print("返回成功标识")
        return isFinish
    }

    /// 获取指定缓存
    func object(forKey key: String) -> T? {
        let filePath = makeFilePath(for: key)
        guard fileManager.fileExists(atPath: filePath) else {
            return nil
        }
        let attributes = try! fileManager.attributesOfItem(atPath: filePath)
        let date = attributes[.modificationDate] as? Date
        let time = date?.timeIntervalSinceNow ?? 0
        guard time > 0 else {
            removeObject(forKey: filePath)
            return nil
        }
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        return transformer.fromData(data)
    }

    /// 删除指定缓存
    func removeObject(forKey key: String) {
        do {
            try fileManager.removeItem(atPath: makeFilePath(for: key))
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func isExpiredObject(forKey key: String) -> Bool {
        let filePath = makeFilePath(for: key)
        let attributes = try? fileManager.attributesOfItem(atPath: filePath)

        guard let date = attributes?[.modificationDate] as? Date else {
            return false
        }
        return date.inThePast
    }

    /// 删除全部缓存
    func removeAll() {
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            print(error.localizedDescription)
        }
        createDirectory()
    }

    /// 删除到期缓存
    func removeExpiredObjects() {
        // 存储位置
        let storageURL = URL(fileURLWithPath: path)

        let resourceKeys: [URLResourceKey] = [
            .isDirectoryKey,
            .contentModificationDateKey,
            .totalFileAllocatedSizeKey
        ]

        var resourceObjects = [ResourceObject]()
        // 要删除的文件
        var filesToDelete = [URL]()
        // 总大小
        var totalSize: UInt = 0

        let fileEnumerator = fileManager.enumerator(
            at: storageURL,
            includingPropertiesForKeys: resourceKeys,
            options: .skipsHiddenFiles,
            errorHandler: nil
        )

        guard let urlArray = fileEnumerator?.allObjects as? [URL] else {
            return
        }

        for url in urlArray {
            guard let resourceValues = try? url.resourceValues(forKeys: Set(resourceKeys)) else {
                continue
            }

            guard resourceValues.isDirectory != true else {
                continue
            }
            // 如果过期记录过期文件的URL
            if let expiryDate = resourceValues.contentModificationDate, expiryDate.inThePast {
                filesToDelete.append(url)
                continue
            }
            // 未过期文件大小
            if let fileSize = resourceValues.totalFileAllocatedSize {
                totalSize += UInt(fileSize)
                resourceObjects.append((url: url, resourceValues: resourceValues))
            }
        }

        // Remove expired objects
        for url in filesToDelete {
            try? fileManager.removeItem(at: url)
        }

        // Remove objects if storage size exceeds max size
        removeResourceObjects(resourceObjects, totalSize: totalSize)
    }

    /// 删除资源文件
    ///
    /// - Parameters:
    ///     - objects: 资源文件路径
    ///     - totalSize: 总大小
    func removeResourceObjects(_ objects: [ResourceObject], totalSize: UInt) {
        guard config.maxSize > 0 && totalSize > config.maxSize else {
            return
        }

        var totalSize = totalSize
        let targetSize = config.maxSize / 2
        // 按过期时间排序
        let sortedFiles = objects.sorted {
            if let time1 = $0.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate,
                let time2 = $1.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate {
                return time1 > time2
            } else {
                return false
            }
        }

        for file in sortedFiles {
            try? fileManager.removeItem(at: file.url)
            // 总体文件大小
            if let fileSize = file.resourceValues.totalFileAllocatedSize {
                totalSize -= UInt(fileSize)
            }
            // 总大小 小于 目标大小 则停止删除
            if totalSize < targetSize {
                break
            }
        }
    }

    /// 计算总磁盘缓存大小。
    func totalSize() -> UInt64 {
        var size: UInt64 = 0
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else { return 0 }
        for pathComponent in contents {
            let filePath = NSString(string: path).appendingPathComponent(pathComponent)
            let attributes = try? fileManager.attributesOfItem(atPath: filePath)
            if let fileSize = attributes?[.size] as? UInt64 {
                size += fileSize
            }
        }
        return size
    }
}

private extension DiskStorage {
    /// 文件路径
    func makeFilePath(for key: String) -> String {
        return "\(path)/\(makeFileName(for: key))"
    }

    /// 文件名
    func makeFileName(for key: String) -> String {
        let fileExtension = URL(fileURLWithPath: key).pathExtension
        let fileName = key
        switch fileExtension.isEmpty {
        case true:
            return fileName
        case false:
            return "\(fileName).\(fileExtension)"
        }
    }

    /// 创建文件夹
    func createDirectory() {
        guard !fileManager.fileExists(atPath: path) else {
            return
        }
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - 检查日期是否过期
fileprivate extension Date {
    /// 检查日期是否过期
    /// Checks if the date is in the past.
    var inThePast: Bool {
        return timeIntervalSinceNow < 0
    }
}
