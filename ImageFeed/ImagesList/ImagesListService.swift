//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.04.2025.
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
}

final class ImagesListService {
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    
    private init() { }
    
    private var lastLoadedPage: Int?
    
    // ...
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            print("Extra task")
            return
        }
        
        lastLoadedPage = photos.count
        
        guard let urlPhotos = URL(string: Constants.baseURL + "/photos?page=\(lastLoadedPage)?per_page=10") else {
            print("[ImagesListService]: URLError")
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlPhotos) { [weak self] error, response, data in
            if let error = error {
                print("[ImagesListService]: NetworkError - Response received an error")
                return
            }
            
            guard let response = response else {
                print("[ImagesListService]: NetworkError - Was received no response code")
                return
            }
            
            guard let data = data else {
                print("[ImagesListService]: NetworkError - Response received no data")
                return
            }
            
            //PhotoResult.decode(data: data)
            
            guard let self = self else { return }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
}
