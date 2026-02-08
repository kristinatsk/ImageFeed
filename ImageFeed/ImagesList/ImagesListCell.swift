import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    private var animationLayers: [CALayer] = []
    
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        isLiked ? likeButton.setImage(UIImage(resource: .likeButtonActive), for: .normal) : likeButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeAnimatedGradients()
        cellImage.image = nil
    }

    
    func showAnimatedGradient() {
        removeAnimatedGradients()
        
        let gradient = CAGradientLayer()
        
        gradient.frame = cellImage.bounds
        gradient.locations = [0, 0.1, 0.3]
        
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        animationLayers.append(gradient)
        cellImage.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
    }
    func removeAnimatedGradients() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
}
