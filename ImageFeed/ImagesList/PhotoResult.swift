//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.04.2025.
//

import Foundation

struct PhotoResult {
    static func decode(data: Data, completion: (Result<[PhotoModel], Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            //print(String(data: data, encoding: .utf8))
            let decodedPhotos = try decoder.decode([PhotoModel].self, from: data)
            completion(.success(decodedPhotos))
        } catch {
            print("[PhotoResult]: Decoding error")
            completion(.failure(error))
        }
    }
}

struct PhotoModel: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let isLiked: Bool
    let welcomeDescription: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case isLiked = "liked_by_user"
        case welcomeDescription = "description"
        case urls
    }
}

struct UrlsResult: Codable {
    let urlLarge: String
    let urlThumb: String
    
    enum CodingKeys: String, CodingKey {
        case urlLarge = "full"
        case urlThumb = "thumb"
    }
}
