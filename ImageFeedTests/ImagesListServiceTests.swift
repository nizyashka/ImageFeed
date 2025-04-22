//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Алексей Непряхин on 22.04.2025.
//

import Testing
@testable import ImageFeed
import XCTest

struct ImageFeedTests {
    
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let imageListService = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        imageListService.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(imageListService.photos.count, 10)
    }
}
