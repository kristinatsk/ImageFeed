import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return nil
        }
        return window
    }
    
    static func show() {
        if UITest.profile || UITest.feed {
            return
        }
        
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        if UITest.profile || UITest.feed {
            return
        }
        
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }

}
