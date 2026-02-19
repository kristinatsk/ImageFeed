import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profilePhotoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .profilePhoto))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя не указано"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@неизвестный_пользователь"
        label.textColor = UIColor(hex: "#AEAFB4")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Профиль не заполнен"
        label.textColor = UIColor(hex: "#FFFFFF")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .exitButton),
            target: self,
            action: #selector(logoutButtonTapped)
        )
        button.tintColor = UIColor(hex: "#F56B6C")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var animationLayers: [CALayer] = []
    
    private var profileImageServiceObserver: NSObjectProtocol?
                                               
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        showAnimatedGradient()
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                
                guard let self else { return }
                self.updateAvatar()
                
            }
        updateAvatar()
        
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1A1B22")
        
        [profilePhotoView, nameLabel, loginLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
        
        
        
        NSLayoutConstraint.activate([
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profilePhotoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profilePhotoView.centerYAnchor)
            
            
        ])
    }
    
    private func showAnimatedGradient() {
        removeAnimatedGradients()
        
        [profilePhotoView, nameLabel, loginLabel, descriptionLabel].forEach { view in
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.locations = [0, 0.1, 0.3]
            gradient.colors = [
                UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            if view == profilePhotoView {
                gradient.cornerRadius = view.bounds.height / 2
            } else {
                gradient.cornerRadius = 0
            }
            animationLayers.append(gradient)
            view.layer.addSublayer(gradient)
            
            let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
            gradientChangeAnimation.duration = 1.0
            gradientChangeAnimation.repeatCount = .infinity
            gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
            gradientChangeAnimation.toValue = [0, 0.8, 1]
            gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        }
    }
    
    private func removeAnimatedGradients() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers = []
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print("imageURL: \(url)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        profilePhotoView.layer.cornerRadius = 35
        profilePhotoView.clipsToBounds = true
        profilePhotoView.kf.indicatorType = .activity
        profilePhotoView.kf.setImage(with: url,
                                     placeholder: placeholderImage,
                                     options: [.forceRefresh]
        ) { result in
            self.removeAnimatedGradients()
            switch result {
            case .success(let value):
                print(value.image)
                
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
        }
    }

    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginLabel.text = profile.loginName.isEmpty ? "@пользователь не указан" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль пуст" : profile.bio
    }
    
    @objc
    private func logoutButtonTapped() {
        showLogoutAlert()
    }
    private func showLogoutAlert() {
        let alert = UIAlertController (
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    private func performLogout() {
        ProfileLogoutService.shared.logout()
        
        guard
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first
        else { return }
        
        let splash = SplashViewController()
        
        window.rootViewController = splash
        window.makeKeyAndVisible()
    }
}
