//
//  APIClient.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/18.
//

import Foundation

final class APIClient {
    // API Document: https://www.flickr.com/services/api/flickr.interestingness.getList.html
    static func fetchFlickrPhotos() async throws -> FlickrResponse {
        var urlComponents = URLComponents(
            string: "https://api.flickr.com/services/rest"
        )!
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "49d464f0832177ce8d85b43ae368c5b9"),
            URLQueryItem(name: "method", value: "flickr.interestingness.getList"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "extras", value: "url_h")
        ]
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError()
        }
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(FlickrResponse.self, from: data)
        default:
            throw NSError()
        }
    }

    static func fetchImageData(urlString: String) async throws -> Data {
        let url = URL(string: urlString)!
        if let data = ImageCache.data(url: url) {
            return data
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError()
        }
        ImageCache.append(url: url, data: data)
        return data
    }
}
