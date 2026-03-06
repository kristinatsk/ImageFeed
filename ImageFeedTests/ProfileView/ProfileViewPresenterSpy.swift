import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    var logoutTapped: Bool = false
    var logoutConfirmed: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func didTapLogout() {
        logoutTapped = true
    }
    func didConfirmLogout() {
        logoutConfirmed = true
    }
}
