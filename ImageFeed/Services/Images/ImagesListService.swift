import UIKit


final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let perPage = 10
    static let shared = ImagesListService()
    private let urlSession = URLSession.shared
    
    func makeImageRequest(path: String, httpMethod: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com\(path)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        
        guard task == nil else { return }
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        let path = "/photos?page=\(nextPage)&per_page=\(perPage)"
        
        guard let request = makeImageRequest(path: path, httpMethod: "GET") else { return }
        
        
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
        
            guard let self = self else { return }
            defer { self.task = nil }
            
            guard let data = data, error == nil else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { $0.toPhoto }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Ошибка декодирования JSON: \(error)")
            }
        }
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let requestPath = "https://api.unsplash.com/photos/\(photoId)/like"
        let httpMethod = isLike ? "POST" : "DELETE"
        
        guard let request = makeImageRequest(path: requestPath, httpMethod: httpMethod) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                completion(.failure(NetworkError.invalidRequest))
                return
            }
            
            DispatchQueue.main.async {
                
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]

                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        
                        self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                        completion(.success(()))
                    } else {
                        completion(.failure(NetworkError.photoNotFound))
                    }
                    
            }
            
        }
        task.resume()
    }
    func reset() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }
}
