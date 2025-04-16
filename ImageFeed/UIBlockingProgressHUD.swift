//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 07.04.2025.
//

import Foundation
import UIKit
import ProgressHUD

class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
