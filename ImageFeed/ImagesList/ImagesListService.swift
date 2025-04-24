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
    private let storage = OAuth2TokenStorage()
    
    private init() { }
    
    private var lastLoadedPage: Int?
    
    // ...
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil {
            print("Extra task")
            return
        }
        
        lastLoadedPage = photos.count / 10
        
        guard let urlPhotos = URL(string: "https://api.unsplash.com/photos?page=\(lastLoadedPage)&per_page=10") else {
            print("[ImagesListService]: URLError")
            return
        }
        
        var request = URLRequest(url: urlPhotos)
        request.httpMethod = "GET"
        guard let token = storage.token else { return }
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoModel], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResult):
                self.toPhoto(from: photoResult)
                self.task = nil
            case .failure(let error):
                print("[ImagesListService]: NetworkOrDecodingError - \(error)")
                self.task = nil
                return
            }
        }
        
//        let task = URLSession.shared.dataTask(with: urlPhotos) { [weak self] data, response, error in
//            if let error = error {
//                print("[ImagesListService]: NetworkError - \(error)")
//                return
//            }
//            
//            guard let response = response else {
//                print("[ImagesListService]: NetworkError - Was received no response code")
//                return
//            }
//            
//            guard let data = data else {
//                print("[ImagesListService]: NetworkError - Response received no data")
//                return
//            }
//            
//            PhotoResult.decode(data: data) { [weak self] result in
//                guard let self = self else { return }
//                
//                switch result {
//                case .success(let photoResult):
//                    self.toPhoto(from: photoResult)
//                case.failure(let error):
//                    print("[ImagesListService]: DecodingError - \(error)")
//                    return
//                }
//            }
//
//            guard let self = self else { return }
//            self.task = nil
//        }
        
        self.task = task
        task.resume()
    }
    
    func toPhoto(from photoResult: [PhotoModel]) {
        photoResult.forEach { photo in
            let id = photo.id
            let size = CGSize(width: photo.width, height: photo.height)
            
            var createdAt: Date? = nil
            if let date = photo.createdAt {
                guard let formattedDate = ISO8601DateFormatter().date(from: date) else {
                    print("[ImagesListService]: DateFormatterError - Was unable to format date")
                    return
                }
                createdAt = formattedDate
            } else {
                print("[ImagesListService]: DateFormatterError - Was unable to find date")
            }
            
            var welcomeDescription: String? = nil
            if let description = photo.welcomeDescription {
                welcomeDescription = description
            } else {
                print("[ImagesListService]: WelcomeDescriptionError - Was unable to find welcome description")
            }
            
            let thumbImageURL = photo.urls.urlThumb
            let largeImageURL = photo.urls.urlLarge
            let isLiked = photo.isLiked
            
            let photo = Photo(id: id,
                              size: size,
                              createdAt: createdAt,
                              welcomeDescription: welcomeDescription,
                              thumbImageURL: thumbImageURL,
                              largeImageURL: largeImageURL,
                              isLiked: isLiked)
            
            DispatchQueue.main.async {
                self.photos.append(photo)
            }
        }
    }
}
