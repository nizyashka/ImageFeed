//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 13.05.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func callNotification()
    func fetchPhotosNextPage()
    func getPhotosCount() -> Int
    func getPhotos() -> [Photo]
    func changeLike(cell: ImagesListCell, indexPath: IndexPath)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    
    func callNotification() {
        imagesListService.imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                view?.updateTableViewAnimated()
            }
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func getPhotosCount() -> Int {
        return imagesListService.photos.count
    }
    
    func getPhotos() -> [Photo] {
        return imagesListService.photos
    }
    
    func changeLike(cell: ImagesListCell, indexPath: IndexPath) {
        guard let view = view else { return }
        let photo = view.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success():
                view.photos = self.imagesListService.photos
                let photoNew = view.photos[indexPath.row]
                view.setIsLiked(cell: cell, photo: photoNew)
            case .failure(let error):
                print("[ImagesListViewPresenter]: Error changing Like - \(error)")
                return
            }
        }
    }
}
