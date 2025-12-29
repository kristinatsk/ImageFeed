import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private let dataStorage = OAuth2TokenStorage.shared
    private(set) var authToken: String? {
        get { dataStorage.token }
        set { dataStorage.token = newValue }
    }
    

    private init() {}
    
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuth2Service.fetchOAuthToken]: AuthServiceError.invalidRequest - code reused")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            print("[OAuth2Service.makeOAuthTokenRequest]: AuthServiceError.invalidRequest - code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else {
                    print("[OAuth2Service.fetchOAuthToken]: NetworkError.urlSessionError - self deallocated")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                switch result {
                case .success(let body):
                    self.authToken = body.accessToken
                    completion(.success(body.accessToken))
                    
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: \(type(of: error)) - \(error)")
                    completion(.failure(error))
                }

                self.task = nil
                self.lastCode = nil
            }
                
                
        }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.oauthTokenURL, resolvingAgainstBaseURL: false) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
        
    }
    
}

// MARK: - Network Client
extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
        
            switch result {
                
            case .success(let data):
                do {
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                } catch {
                    print("[OAuth2Service.object]: NetworkError.decodingError - failed to decode response")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("[OAuth2Service.object]: \(type(of: error)) - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
