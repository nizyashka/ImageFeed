//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 11.04.2025.
//

import Foundation
import UIKit

enum Errors: Error {
    case decodingError
}

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("Extra task")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService] - Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = storage.token else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
//        let task = urlSession.data(for: request) { [weak self] result in
//            switch result {
//            case .success(let data):
//                switch UserResult.decode(from: data) {
//                case .success(let profileImageURL):
//                    //print(profileImageURL)
//                    self?.avatarURL = profileImageURL
//                    completion(.success(profileImageURL))
//                    NotificationCenter.default
//                        .post(
//                            name: ProfileImageService.didChangeNotification,
//                            object: self,
//                            userInfo: ["URL": profileImageURL])
//                case .failure(let error):
//                    print(error)
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                print(error)
//                completion(.failure(error))
//            }
//            self?.task = nil
//        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let decodedProfileImages):
                guard let profileImages = decodedProfileImages.profileImages else { return }
                guard let smallProfileImage = profileImages["small"] else { return }
                self?.avatarURL = smallProfileImage
                completion(.success(smallProfileImage))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": smallProfileImage])
            case .failure(let error):
                print("[ProfileImageService]: NetworkOrDecodingError - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        task.resume()
    }
}

struct UserResult: Codable {
    let profileImages: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case profileImages = "profile_image"
    }
    
    static func decode(from data: Data) -> Result<String, Error> {
        let decoder = JSONDecoder()
        
        do {
            let decodedProfileImages = try decoder.decode(UserResult.self, from: data)
            
            guard let profileImages = decodedProfileImages.profileImages else { return .failure(Errors.decodingError) }
            guard let smallProfileImage = profileImages["small"] else { return .failure(Errors.decodingError) }
            
            return .success(smallProfileImage)
        } catch {
            print("Error decoding")
            return .failure(error)
        }
    }
}
