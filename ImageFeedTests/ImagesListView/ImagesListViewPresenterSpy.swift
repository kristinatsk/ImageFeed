import ImageFeed
import Foundation

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var numberOfPhotos: Int = 0
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    
    
    var tapLikeCalled: Bool = false
    
    var didReachEndOfList: Bool = false
    var receivedIndex: Int?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at index: Int) -> ImageFeed.Photo? {
        nil
    }
    
    func didTapLike(at index: Int) {
        tapLikeCalled = true
    }
    
    func didReachEndOfList(at index: Int) {
        didReachEndOfList = true
        receivedIndex = index
    }
    
    
    
}

