@testable import ImageFeed
import XCTest

class ImagesListViewTests: XCTestCase {
    func testViewControllerCallViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewDidLoadCallsShowLoadingAndFetchNextPage() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.showLoadingCalled)
        XCTAssertTrue(fakeHelper.fetchNextPageCalled)
    }
    
    private func makePhoto(id: String = UUID().uuidString) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 1, height: 1),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false)
    }
    
    func testPresenterCallsDidReachEndOfList() {
        //given
    
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        fakeHelper.photos = [makePhoto(), makePhoto(), makePhoto()]
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        
        //when
        presenter.didReachEndOfList(at: 2)
        
        //then
        XCTAssertTrue(viewController.showLoadingCalled)
        XCTAssertTrue(fakeHelper.fetchNextPageCalled)
        
    }
    
    func testDidReachEndOfListDoesNotFetchNextPageForNonLastIndex() {
        //given
        
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        fakeHelper.photos = [makePhoto(), makePhoto(), makePhoto()]
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        
        //when
        presenter.didReachEndOfList(at: 1)
        
        //then
        XCTAssertFalse(viewController.showLoadingCalled)
        XCTAssertFalse(fakeHelper.fetchNextPageCalled)
    }
    
    func testDidTapLikeCallsUpdatePhotoOnSuccess() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        fakeHelper.photos = [makePhoto(), makePhoto(), makePhoto()]
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        
        //when
        presenter.didTapLike(at: 0)
        
        //then (before completion)
        XCTAssertTrue(viewController.showLoadingCalled)
        
        let expectation = expectation(description: "Success completion")
        
        //when (completion success)
        fakeHelper.storedCompletion?(.success(()))
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        //then (after completion)
        XCTAssertTrue(viewController.hideLoadingCalled)
        XCTAssertTrue(viewController.updatePhotoCalled)
        XCTAssertFalse(viewController.displayErrorCalled)
    }
    func testDidTapLikeDisplaysErrorOnFailure() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        fakeHelper.photos = [makePhoto()]
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //when
        presenter.didTapLike(at: 0)
        
        XCTAssertTrue(viewController.showLoadingCalled)
        
        let expectation = expectation(description: "Failure completion")
        
        fakeHelper.storedCompletion?(.failure(NSError(domain: "", code: 0)))
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        //then
        XCTAssertTrue(viewController.hideLoadingCalled)
        XCTAssertTrue(viewController.displayErrorCalled)
        XCTAssertFalse(viewController.updatePhotoCalled)
    }
    
    func testDidReceivePhotosUpdateInsertsNewIndexes() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        
        let photo1 = makePhoto(id: "1")
        let photo2 = makePhoto(id: "2")
        
        fakeHelper.photos = [photo1, photo2]
        
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        //initial load
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //when
        let photo3 = makePhoto(id: "3")
        let photo4 = makePhoto(id: "4")
        fakeHelper.photos = [photo1, photo2, photo3, photo4]
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
        XCTAssertEqual(viewController.receivedInsertedIndexes, [2, 3])
    }
    
    func testDidReceivePhotosUpdateDoesNotInsertWhenNoNewPhotos() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let fakeHelper = FakeImagesListHelper()
        
        let photo1 = makePhoto(id: "1")
        let photo2 = makePhoto(id: "2")
        
        fakeHelper.photos = [photo1, photo2]
        
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        presenter.view = viewController
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        viewController.updateTableViewAnimatedCalled = false
        
        //when
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //then
        XCTAssertFalse(viewController.updateTableViewAnimatedCalled)
    }
    
    func testPhotoAtValidIndexReturnsPhoto() {
        //given
        let fakeHelper = FakeImagesListHelper()
        let photo = makePhoto(id: "123")
        fakeHelper.photos = [photo]
        
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //when
        let result = presenter.photo(at: 0)
        
        //then
        XCTAssertEqual(result?.id, "123")
    }
    
    func testPhotoAtInvalidIndexReturnsNil() {
        let fakeHelper = FakeImagesListHelper()
        fakeHelper.photos = [makePhoto(id: "1")]
        
        let presenter = ImagesListViewPresenter(helper: fakeHelper)
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        //when
        let result = presenter.photo(at: 5)
        
        //then
        XCTAssertNil(result)
    }
    
}
