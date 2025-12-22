import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profilePhotoView = UIImageView(image: UIImage(resource: .profilePhoto))
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var logoutButton = UIButton()
    private var profileImageServiceObserver: NSObjectProtocol?
                                               
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                
                guard let self = self else { return }
                self.updateAvatar()
                
            }
        updateAvatar()
        
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1A1B22")
        profilePhotoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePhotoView)
        
        nameLabel.text = "Имя не указано"
        nameLabel.textColor = UIColor(hex: "#FFFFFF")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        loginLabel.text = "@неизвестный_пользователь"
        loginLabel.textColor = UIColor(hex: "#AEAFB4")
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        descriptionLabel.text = "Профиль не заполнен"
        descriptionLabel.textColor = UIColor(hex: "#FFFFFF")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        logoutButton = UIButton.systemButton(
            with: UIImage(resource: .exitButton),
            target: self,
            action: #selector(logoutButtonTapped))
        logoutButton.tintColor = UIColor(hex: "#F56B6C")
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
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
    

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print("imageURL: \(url)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profilePhotoView.kf.indicatorType = .activity
        profilePhotoView.kf.setImage(with: url,
                                     placeholder: placeholderImage,
                                     options: [.processor(processor)]
        ) { result in
            
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
        
    }
}
