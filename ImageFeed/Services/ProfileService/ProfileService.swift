import Foundation

struct Profile {
    let username: String
    let loginName: String
    let name: String
    let bio: String?
}

struct ProfileResult: Codable {
    let firstName: String
    let lastName: String?
    let username: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case bio
        
    }
}



final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
       
        task?.cancel()
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: URLError - failed to build request")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
        
            switch result {
            case .success(let result):
                let fullName = [result.firstName, result.lastName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                    let profile = Profile(
                        username: result.username,
                        loginName: "@\(result.username)",
                        name: fullName,
                        bio: result.bio
                    )
                    self?.profile = profile
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { avatarResult in
                
                    if case .failure(let error) = avatarResult {
                        print("[ProfileService.fetchProfile]: Failed to fetch avatar URL — \(error.localizedDescription)")
                    }
                }
                    completion(.success(profile))
                    
               
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(type(of: error)) - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
        
    }
    func reset() {
        profile = nil
    }
}
