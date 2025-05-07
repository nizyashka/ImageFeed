//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 22.04.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    var imageListServiceObserver: NSObjectProtocol?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage()
    private var lastLoadedPage: Int = 0
    
    private init() { }
    
    private func makeRequest() -> URLRequest? {
        var components = URLComponents(string: Constants.defaultBaseURL.absoluteString + "photos")
        components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url, let token = storage.token else {
            print("[ImagesListService]: URLError Or Missing Token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchPhotosNextPage() {
        if task != nil {
            print("[ImagesListService]: Extra task")
            return
        }
        
        guard let request = makeRequest() else {
            print("[ImagesListService]: RequestError")
            return
        }
        
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("[ImagesListService]: NetworkError - \(error)")
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
            
            PhotoResult.decode(data: data) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let photoResult):
                    self.toPhoto(from: photoResult)
                case.failure(let error):
                    print("[ImagesListService]: DecodingError - \(error)")
                    return
                }
            }
            
            guard let self = self else { return }
            self.task = nil
        }
        
        task?.resume()
    }
    
    private func toPhoto(from photoResult: [PhotoModel]) {
        photoResult.forEach { photo in
            let newPhoto = Photo(from: photo)
            
            DispatchQueue.main.async {
                self.photos.append(newPhoto)
            }
        }
        
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: nil)
        lastLoadedPage += 1
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like"), let token = storage.token else {
            print("[ImagesListService]: URLError Or Missing Token")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLiked ? "DELETE" : "POST"
        
        URLSession.shared.data(for: request) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                print("[ImagesListService]: Error changing Like - \(error)")
                completion(.failure(error))
                return
            }
        }.resume()
    }
    
    func cleanPhotos() {
        photos.removeAll()
    }
}
