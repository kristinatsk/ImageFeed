import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            fatalError("Failed to instantiate ImagesListViewController")
        }
        let presenter = ImagesListViewPresenter()
        imagesListViewController.presenter = presenter
        presenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        
        let profilePresenter = ProfileViewPresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil)
        
        viewControllers = [imagesListViewController, profileViewController]
    }
}
