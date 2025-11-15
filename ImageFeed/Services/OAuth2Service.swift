import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Ошибка: не удалось создать URLRequest")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print("Успешно получен токен: \(response.accessToken)")
            
                    OAuth2TokenStorage().token = response.accessToken
                
                    DispatchQueue.main.async {
                        completion(.success(response.accessToken))
                    }
                } catch {
                    print("Ошибка декодирования JSON: \(error)")
                    print("Ответ сервера (при ошибке декодирования):")
                    print(String(data: data, encoding: .utf8) ?? "Пустой ответ")
                    
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                }
                
            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("Ошибка от сервера Unsplash: статус-код \(statusCode)")
                    print("Ответ сервера (HTTP-ошибка):")
                    print(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "Нет данных")
                case NetworkError.urlRequestError(let urlRequestError):
                    print(" Сетевая ошибка запроса: \(urlRequestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("Ошибка URLSession: не удалось получить ответ")
                default:
                    print("Неизвестная ошибка \(error)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}
