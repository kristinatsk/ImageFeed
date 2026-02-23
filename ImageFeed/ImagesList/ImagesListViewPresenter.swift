import Foundation

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    
    var numberOfPhotos: Int { get }
    
    func viewDidLoad()
    func photo(at index: Int) -> Photo?
    func didTapLike(at index: Int)
    func didReachEndOfList(at index: Int)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var numberOfPhotos: Int {
        photos.count
    }
    private var photos: [Photo] = []
    private let helper: ImagesListHelperProtocol
    private var observer: NSObjectProtocol?
    
    init(helper: ImagesListHelperProtocol = ImagesListHelper()) {
        self.helper = helper
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.didReceivePhotosUpdate()
        }
    }
    
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func viewDidLoad() {

        view?.showLoading()
        helper.fetchNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard photos.indices.contains(index) else { return nil }
            return photos[index]
    }
    
    func didReachEndOfList(at index: Int) {
        guard photos.indices.contains(index) else { return }
        guard index == photos.count - 1 else { return }
        
        view?.showLoading()
        helper.fetchNextPage()
    }
    

    private func didReceivePhotosUpdate() {
        let oldCount = photos.count
        let newPhotos = helper.photos
        
        photos = newPhotos
        
        let newCount = photos.count
        
        let insertedIndexes = Array(oldCount..<newCount)
        if oldCount < newCount {
            view?.updateTableViewAnimated(insertedIndexes: insertedIndexes)
        }
        view?.hideLoading()
    }
    func didTapLike(at index: Int) {
        guard photos.indices.contains(index) else { return }
        let photo = photos[index]
        
        view?.showLoading()
        
        helper.toggleLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success:
                    self.photos = self.helper.photos
                    self.view?.updatePhoto(at: index)
                    
                case .failure:
                    self.view?.displayError(message: "Что-то пошло не так")
                }
            }
        }
    }
    
}
