import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    
    func updateTableViewAnimated(insertedIndexes: [Int])
    func updatePhoto(at index: Int)
    func showLoading()
    func hideLoading()
    func displayError(message: String)
 
    
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {

    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    var presenter: ImagesListViewPresenterProtocol?
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        presenter?.viewDidLoad()
    }
    
    

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath.row) else { return }
        
        cell.showAnimatedGradient()
        
        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(resource: .stub)
        
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: placeholder
        ) { [weak self, weak cell] result in
        
            guard
                let self,
                let cell,
                let currentIndexPath = self.tableView.indexPath(for: cell),
                currentIndexPath == indexPath
            else { return }
            cell.removeAnimatedGradients()
        }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(resource: .likeButtonActive) : UIImage(resource: .likeButtonNoActive)
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            guard let photo = presenter?.photo(at: indexPath.row) else { return }
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
        presenter?.didReachEndOfList(at: indexPath.row)
    
    }
    
    func updatePhoto(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func displayError(message: String) {
        showLikeErrorAlert()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfPhotos ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
    
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func updateTableViewAnimated(insertedIndexes: [Int]) {
        let indexPaths = insertedIndexes.map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
    }
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)


        }
    }

extension ImagesListViewController {
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
