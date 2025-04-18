//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 07.04.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            print("Extra task")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let url = URL(string: "https://api.unsplash.com/me")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
//        let task = urlSession.data(for: request) { [weak self] result in
//            switch result {
//            case .success(let data):
//                switch ProfileResult.decode(from: data) {
//                case .success(let responseBody):
//                    self?.profile = responseBody
//                    completion(.success(responseBody))
//                    print(responseBody)
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
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let decodedResponse):
                var username: String?
                var name: String?
                var loginName: String?
                var bio: String?
                
                if let userName = decodedResponse.username {
                    username = userName
                    loginName = "@\(userName)"
                }
                
                if let firstName = decodedResponse.firstName, let lastName = decodedResponse.lastName {
                    name = "\(firstName) \(lastName)"
                } else if let firstName = decodedResponse.firstName {
                    name = firstName
                } else if let lastName = decodedResponse.lastName {
                    name = lastName
                }
                
                bio = decodedResponse.bio
                
                let user = Profile(username: username,
                                   name: name,
                                   loginName: loginName,
                                   bio: bio)
                
                self?.profile = user
                completion(.success(user))
            case .failure(let error):
                print("[ProfileService]: NetworkOrDecodingError - \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        task.resume()
    }
}

struct ProfileResult: Codable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
    
    static func decode(from data: Data) -> Result<Profile, Error> {
        let decoder = JSONDecoder()
        do {
            let decodedResponse = try decoder.decode(ProfileResult.self, from: data)
            
            var username: String?
            var name: String?
            var loginName: String?
            var bio: String?
            
            if let userName = decodedResponse.username {
                username = userName
                loginName = "@\(userName)"
            }
            
            if let firstName = decodedResponse.firstName, let lastName = decodedResponse.lastName {
                name = "\(firstName) \(lastName)"
            } else if let firstName = decodedResponse.firstName {
                name = firstName
            } else if let lastName = decodedResponse.lastName {
                name = lastName
            }
            
            bio = decodedResponse.bio
            
            let user = Profile(username: username,
                               name: name,
                               loginName: loginName,
                               bio: bio)
            return .success(user)
        } catch {
            print("Error decoding received data.")
            return .failure(error)
        }
    }
}

struct Profile: Decodable {
    var username: String?
    var name: String?
    var loginName: String?
    var bio: String?
}
