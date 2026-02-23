import ImageFeed
import Foundation

final class FakeLogoutService: ProfileLogoutServiceProtocol {
    var logoutCalled: Bool = false
    func logout() {
        logoutCalled = true
    }
    
}
