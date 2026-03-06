import Foundation

enum UITest {
    static let profile = ProcessInfo.processInfo.arguments.contains("UI_TEST_PROFILE")
    static let feed = ProcessInfo.processInfo.arguments.contains("UI_TEST_FEED")
    static let auth =  ProcessInfo.processInfo.arguments.contains("UI_TEST_AUTH")
}
