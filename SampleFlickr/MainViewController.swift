//
//  MainViewController.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/10.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                let response = try await fetch()
                print(response)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    // API Document: https://www.flickr.com/services/api/flickr.interestingness.getList.html
    func fetch() async throws -> FlickrResponse {
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
        print("Response Status Code: " + String(httpResponse.statusCode))
        switch httpResponse.statusCode {
        case 200:
            print(try JSONSerialization.jsonObject(with: data) as! [String: Any])
            return try JSONDecoder().decode(FlickrResponse.self, from: data)
        default:
            throw NSError()
        }
    }
}
