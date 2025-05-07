//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 03.03.2025.
//

import Foundation
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fullImageURL: URL?
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        setImage()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let items = [image]
        let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(share, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func setImage() {
        UIBlockingProgressHUD.show()
        imageView.contentMode = .center
        imageView.kf.setImage(with: fullImageURL,
                              placeholder: UIImage(named: "placeholderImage.jpeg")) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            self.imageView.contentMode = .scaleToFill
            switch result {
            case .success(let imageResult):
                image = imageResult.image
                guard let image = image else { return }
                imageView.frame.size = image.size
                rescaleAndCenterImageInScrollView(image: image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так.", message: "Попробовать ещё раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })
            
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            self.setImage()
        })
        self.present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
