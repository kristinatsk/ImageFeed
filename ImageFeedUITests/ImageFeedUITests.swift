
import XCTest

final class ImageFeedUITests: XCTestCase {
    
    override func setUpWithError() throws {
        
        continueAfterFailure = false
        
    }
    
    func testAuth() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TEST_AUTH"]
        app.launch()
        let button = app.buttons["Authenticate"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        
        button.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("email@gmail.com")
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        if !passwordTextField.isHittable {
            webView.swipeUp()
        }
        passwordTextField.tap()
        passwordTextField.typeText("password")
        webView.tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        
    }
    
    func testFeed() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TEST_FEED"]
        app.launch()
        
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        let cell = table.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        let likeButton = cell.buttons["LikeButton"]
        print(app.debugDescription)
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        while !likeButton.isHittable {
            table.swipeUp()
        }

        likeButton.tap()
        likeButton.tap()

        cell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        
        backButton.tap()
                    
        }
        
        func testProfile() throws {
            let app = XCUIApplication()
            app.launchArguments = ["UI_TEST_PROFILE"]
            app.launch()
            
            XCTAssertTrue(app.staticTexts["ProfileLoginLabel"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["ProfileNameLabel"].exists)

            let logoutButton = app.buttons["ProfileLogoutButton"]
            XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
            logoutButton.tap()
            
            print(app.debugDescription)
            
            let alert = app.alerts["Пока, пока!"]
            XCTAssertTrue(alert.waitForExistence(timeout: 5))
            
            alert.buttons["Да"].tap()
            
            
        }
        
        
    }
    

