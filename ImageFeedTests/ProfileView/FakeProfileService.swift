import ImageFeed
import Foundation

final class FakeProfileService: ProfileServiceProtocol {
    var profile: ImageFeed.Profile?
    
    init(profile: ImageFeed.Profile? = nil) {
        self.profile = profile
    }
}
