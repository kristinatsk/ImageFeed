import UIKit

protocol ImagesListServiceDelegate: AnyObject {
    func imageListCellDidTaplike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
    }
}
