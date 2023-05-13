//
//  FlickrResponse.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/14.
//

import Foundation

struct FlickrResponse: Codable {
    var photos: FlickrPhotos
}

struct FlickrPhotos: Codable {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: Int
    var photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable, Hashable {
    var id: String
    var urlString: String?

    enum CodingKeys: String, CodingKey {
        case id
        case urlString = "url_h"
    }
}
