//
//  MainViewController.swift
//  SampleFlickr
//
//  Created by fuwamaki on 2023/05/10.
//

import UIKit

class MainViewController: UIViewController {

    private enum Section: CaseIterable {
        case main
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(
                UINib(nibName: String(describing: ImageCollectionCell.self), bundle: Bundle.main),
                forCellWithReuseIdentifier: String(describing: ImageCollectionCell.self)
            )
            collectionView.delegate = self
        }
    }

    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = UIColor.systemMint
        indicator.isHidden = true
        return indicator
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, FlickrPhoto>!
    private var flickrPhotos: [FlickrPhoto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicator)
        setupCollectionViewLayout()
        setupDataSource()
        Task {
            do {
                let response = try await fetch()
                self.flickrPhotos = response.photos.photo.filter { $0.urlString != nil }
                var snapshot = NSDiffableDataSourceSnapshot<Section, FlickrPhoto>()
                snapshot.appendSections(Section.allCases)
                snapshot.appendItems(self.flickrPhotos, toSection: .main)
                await dataSource.apply(snapshot, animatingDifferences: false)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    private func setupCollectionViewLayout() {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalWidth(1/3)
        ))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/3)
            ),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, FlickrPhoto>(
            collectionView: collectionView
        ) { collectionView, indexPath, flickrPhoto in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ImageCollectionCell.self),
                for: indexPath
            ) as! ImageCollectionCell
            cell.render(flickrPhoto: flickrPhoto)
            return cell
        }
    }

    // API Document: https://www.flickr.com/services/api/flickr.interestingness.getList.html
    private func fetch() async throws -> FlickrResponse {
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
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let flickrPhoto = self.flickrPhotos[indexPath.row]
        let viewController = DetailViewController.instantiate(flickrPhoto: flickrPhoto)
        present(viewController, animated: true)
    }
}
