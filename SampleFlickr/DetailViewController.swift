//
//  DetailViewController.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/14.
//

import UIKit

final class DetailViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!

    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = UIColor.systemMint
        indicator.isHidden = true
        return indicator
    }()

    private var flickrPhoto: FlickrPhoto!

    static func instantiate(flickrPhoto: FlickrPhoto) -> DetailViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = storyboard.instantiateInitialViewController() as! DetailViewController
        viewController.flickrPhoto = flickrPhoto
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            self.setupImage(nil)
            self.indicator.startAnimating()
            let data = try await APIClient.fetchImageData(urlString: flickrPhoto.urlString!)
            self.indicator.stopAnimating()
            self.setupImage(UIImage(data: data))
        }
    }

    @MainActor private func setupImage(_ image: UIImage?) {
        imageView.image = image
    }
}
