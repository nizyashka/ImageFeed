//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.03.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    init(task: URLSessionTask? = nil, lastCode: String? = nil) {
        self.task = task
        self.lastCode = lastCode
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: Constants.baseURL)
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                handler(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                handler(.success(responseBody.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: NetworkOrDecodingError - \(error.localizedDescription)")
                handler(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
}
