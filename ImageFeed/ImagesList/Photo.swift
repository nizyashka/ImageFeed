//
//  PhotoModel.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 07.05.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init (from photo: PhotoModel) {
        let id = photo.id
        let size = CGSize(width: photo.width, height: photo.height)
        
        var createdAt: Date? = nil
        if let date = photo.createdAt {
            createdAt = ISO8601DateFormatter().date(from: date)
        }
        
        var welcomeDescription: String? = nil
        if let description = photo.welcomeDescription {
            welcomeDescription = description
        }
        
        let thumbImageURL = photo.urls.urlThumb
        let largeImageURL = photo.urls.urlLarge
        let isLiked = photo.isLiked
        
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
    
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}
