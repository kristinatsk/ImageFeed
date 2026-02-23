import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var displayProfileCalled: Bool = false
    var receivedProfile: Profile?
    
    var displayAvatarCalled: Bool = false
    var receivedAvatarURL: URL?
    
    var navigateToSplashCalled: Bool = false
    var showLogoutConfirmationCalled: Bool = false
    
    func displayProfile(profile: ImageFeed.Profile) {
        displayProfileCalled = true
        receivedProfile = profile
    }
    
    func displayAvatar(url: URL?) {
        displayAvatarCalled = true
        receivedAvatarURL = url
    }
    
    func navigateToSplash() {
        navigateToSplashCalled = true
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
    
    
    
}
