import Foundation

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}

public protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}
public protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

public protocol ProfileLogoutServiceProtocol {
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    private var observer: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    deinit {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    func viewDidLoad() {
        if UITest.profile {
                let profile = Profile(
                    username: "test_user",
                    loginName: "@test_user", name: "Test User",
                    bio: "Test bio"
                )

                view?.displayProfile(profile: profile)
                view?.displayAvatar(url: nil)
                return
            }
        guard let profile = profileService.profile else {
            return
        }
        view?.displayProfile(profile: profile)
        
        if let avatarURLString = profileImageService.avatarURL,
           let url = URL(string: avatarURLString) {
            view?.displayAvatar(url: url)
        }
        
        observer = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            guard let self else { return }
            
            if let avatarURLString = self.profileImageService.avatarURL,
               let url = URL(string: avatarURLString) {
                self.view?.displayAvatar(url: url)
            }
        }
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func didConfirmLogout() {
        profileLogoutService.logout()
        view?.navigateToSplash()
        
    }
    
    
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}
