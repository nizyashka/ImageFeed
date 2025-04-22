//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.04.2025.
//

import Foundation

struct UrlsResult: Codable {
    let urlLarge: String
    let urlThumb: String
    
    enum CodingKeys: String, CodingKey {
        case urlLarge = "full"
        case urlThumb = "thumb"
    }
}
