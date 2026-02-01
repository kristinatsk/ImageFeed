import Foundation
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case invalidResponse
    case emptyData
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case photoNotFound
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        return dataTask(with: request) { data, response, error in
            
            if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            guard let data = data, !data.isEmpty else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.emptyData))
                return
            }
            fulfillCompletionOnTheMainThread(.success(data))
        }
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученные данные: \(jsonString)")
                }
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("Ошибка декодирования: \(decodingError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        }
        return task
    }
}
