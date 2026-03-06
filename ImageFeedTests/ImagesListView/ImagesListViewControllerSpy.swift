import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    
    var presenter: ImageFeed.ImagesListViewPresenterProtocol?
    var showLoadingCalled: Bool = false
    
    var hideLoadingCalled: Bool = false
    
    var updatePhotoCalled: Bool = false
    var receivedIndex: Int?
    
    var updateTableViewAnimatedCalled = false
    var receivedInsertedIndexes: [Int]?
    
    var displayErrorCalled: Bool = false
    
    var reloadDataCalled = false

    
    func updateTableViewAnimated(insertedIndexes: [Int]) {
        updateTableViewAnimatedCalled = true
        receivedInsertedIndexes = insertedIndexes
    }
    
    func updatePhoto(at index: Int) {
        updatePhotoCalled = true
        receivedIndex = index
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func displayError(message: String) {
        displayErrorCalled = true
    }
    func reloadData() {
        reloadDataCalled = true
    }
    
    
}
