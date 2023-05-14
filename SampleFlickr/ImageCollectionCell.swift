//
//  ImageCollectionCell.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/14.
//

import UIKit

final class ImageCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
    }

    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = self.center
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = UIColor.systemMint
        indicator.isHidden = true
        return indicator
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(indicator)
    }

    internal func render(flickrPhoto: FlickrPhoto) {
        Task {
            self.setupImage(nil)
            self.indicator.startAnimating()
            let data = try await fetchImageData(urlString: flickrPhoto.urlString!)
            self.indicator.stopAnimating()
            self.setupImage(UIImage(data: data))
        }
    }

    @MainActor private func setupImage(_ image: UIImage?) {
        imageView.image = image
    }

    private func fetchImageData(urlString: String) async throws -> Data {
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

final class ImageCache {
    private static var dataList: [URL: Data] = [:]

    static func data(url: URL) -> Data? {
        dataList[url]
    }

    static func append(url: URL, data: Data) {
        dataList[url] = data
    }
}
