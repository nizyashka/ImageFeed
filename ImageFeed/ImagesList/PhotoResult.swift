//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.04.2025.
//

import Foundation

struct PhotoResult: Codable {
    let photos: [PhotoModel]
    
    static func decode(data: Data) -> Result<PhotoResult, Error> {
        let decoder = JSONDecoder()
        
        do {
            let decodedPhotos = try decoder.decode(self, from: data)
            return .success(decodedPhotos)
        } catch {
            print("[PhotoResult]: Decoding error")
            return .failure(error)
        }
    }
}

struct PhotoModel: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let isLiked: Bool
    let welcomeDescription: String?
    let urls: UrlsResult
}
