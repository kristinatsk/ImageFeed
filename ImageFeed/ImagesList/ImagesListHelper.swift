import Foundation

public protocol ImagesListHelperProtocol {
    var photos: [Photo] { get }
    func fetchNextPage()
    func toggleLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListHelper: ImagesListHelperProtocol {
    private let service: ImagesListService = .shared
    
    var photos: [Photo] {
        service.photos
    }
    
    func fetchNextPage() {
        service.fetchPhotosNextPage()
    }
    
    func toggleLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, any Error>) -> Void) {
        service.changeLike(photoId: photoId, isLike: isLike, completion)
    }
}
