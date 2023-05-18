//
//  ImageCache.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/18.
//

import Foundation

final class ImageCache {
    private static var dataList: [URL: Data] = [:]

    static func data(url: URL) -> Data? {
        dataList[url]
    }

    static func append(url: URL, data: Data) {
        dataList[url] = data
    }
}
