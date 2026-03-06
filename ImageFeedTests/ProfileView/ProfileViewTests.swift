@testable import ImageFeed
import XCTest

class ProfileViewTests: XCTestCase {
    func testViewControllerCallViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testPresenterCallsDisplayProfile() {
        //given
        let profile = Profile(
            username: "test",
            loginName: "@test",
            name: "Test user",
            bio: "Bio")
        
        let viewController = ProfileViewControllerSpy()
        let fakeProfileViewService = FakeProfileService(profile: profile)
        let presenter = ProfileViewPresenter(profileService: fakeProfileViewService)
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.displayProfileCalled)
        XCTAssertEqual(viewController.receivedProfile?.username, "test")
    }
    
    func testDidConfirmLogoutCallsLogoutAndNavigate() {
        //given
        let viewController = ProfileViewControllerSpy()
        let fakeLogoutService = FakeLogoutService()
        let presenter = ProfileViewPresenter(profileLogoutService: fakeLogoutService)
        presenter.view = viewController
        
        //when
        presenter.didConfirmLogout()
        
        //then
        XCTAssertTrue(fakeLogoutService.logoutCalled)
        XCTAssertTrue(viewController.navigateToSplashCalled)
    }
    
    func testDidTapLogoutCallsShowLogoutConfirmation() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = viewController
        
        //when
        presenter.didTapLogout()
        
        //then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled)
    }
}
