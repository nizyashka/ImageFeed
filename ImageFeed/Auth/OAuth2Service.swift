//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.03.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL = URL(string: Constants.baseURL)
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        )
        guard let url = url else {
            fatalError("No such URL.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        let session = URLSession.shared
        let task = session.data(for: request) { result in
            switch result {
            case .success(let data):
                switch OAuthTokenResponseBody.decode(from: data) {
                case .success(let responseBody):
                    handler(.success(responseBody.accessToken))
                case .failure(let error):
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
        task.resume()
    }
}
