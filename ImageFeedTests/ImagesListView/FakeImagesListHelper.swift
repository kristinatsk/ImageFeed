import ImageFeed
import Foundation

final class FakeImagesListHelper: ImagesListHelperProtocol {
    var photos: [ImageFeed.Photo] = []
    var fetchNextPageCalled: Bool = false
    
    var toggleLikeCalled: Bool = false
    var storedCompletion: ((Result<Void, Error>) -> Void)?
    
    func fetchNextPage() {
        fetchNextPageCalled = true
    }
    
    func toggleLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, any Error>) -> Void) {
        toggleLikeCalled = true
        storedCompletion = completion
    }
    
    
}
