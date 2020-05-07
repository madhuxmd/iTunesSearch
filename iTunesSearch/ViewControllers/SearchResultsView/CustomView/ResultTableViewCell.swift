


import UIKit

class ResultTableViewCell: UITableViewCell {
    static let nibName = "ResultTableViewCell"
    static let reuseId = "ResultTableViewCellId"

    // MARK: - Outlets

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        artworkImageView.image = nil
        nameLabel.text = nil
        genreLabel.text = nil
    }

    func configure(_ result: iTunesSearchResult) {
        DispatchQueue.main.async {
            self.nameLabel.text = result.name
            self.genreLabel.text = result.genre

            DispatchQueue.global().async {
                guard
                    let urlString = result.artwork,
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
}
