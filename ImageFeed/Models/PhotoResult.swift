import Foundation
import CoreGraphics

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let isLiked: Bool?
    let urls: UrlsResult
    
    var size: CGSize{
        CGSize(width: width, height: height)
    }
    var thumbImageURL: String {
        urls.thumb
    }
    
    var largeImageURL: String {
        urls.full
    }
    
    var toPhoto: Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked ?? false)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls

    }
}
struct UrlsResult: Codable {
    let thumb: String
    let full: String
}
