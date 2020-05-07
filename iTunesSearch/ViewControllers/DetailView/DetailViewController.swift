

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Properties

    static let storyboardId = "DetailsViewController"
    var result: iTunesSearchResult?
    var iTunesUrl: URL?

    // MARK: - Outlets

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iTunesButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            guard let result = self.result else {
                return
            }
            self.titleLabel.text = result.name
            self.subtitleLabel.text = result.genre
            if let urlString = result.url {
                self.iTunesUrl = URL(string:urlString )
            }
            self.iTunesButton.isEnabled = self.iTunesUrl != nil

            DispatchQueue.global().async {
                guard let urlString = self.result?.artwork,
                    let imageUrl = URL(string: urlString),
                    let imageData = try? Data(contentsOf: imageUrl) else {
                        return
                }

                DispatchQueue.main.async { [weak self] in
                    self?.artworkImageView.image = UIImage(data: imageData)
                }
            }
        }
    }

    // MARK: - Helper Methods
    class func viewControllerForResult(_ result: iTunesSearchResult) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: DetailViewController.storyboardId)

        if let detailViewController = viewController as? DetailViewController {
            detailViewController.result = result
        }

        return viewController
    }

    // MARK: - IBActions

    @IBAction func iTunesButtonTapped(_ sender: Any) {
        guard let url = iTunesUrl,
            UIApplication.shared.canOpenURL(url) else {
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        FavoriteManager.favoriteItem(result) { [weak self] (success) in
            self?.displayFavoritedAlert(itemSaved: success, completion: {
                DispatchQueue.main.async {
                    sender.imageView?.image = UIImage(systemName: success ? "star.fill" : "star")
                    sender.setTitle(success ? "Favorite": "Unfavorite", for: .normal)
                }
            })
        }
    }
}

extension DetailViewController {
    func displayFavoritedAlert(itemSaved: Bool, completion: @escaping () -> Void ) {
        DispatchQueue.main.async { [weak self] in
            let title = itemSaved == true ? "Saved to Favorites" : nil
            let message = itemSaved == true ? nil : "There was an issue saving, please try again"
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self?.present(alertController, animated: true, completion: completion)
        }
    }

    func displayLoadingAlert() {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Oops. There was an error loading the data", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self?.present(alertController, animated: true, completion: {
                self?.dismiss(animated: true, completion: nil)
            })
        }
    }
}
