import UIKit

extension UIApplication {
    func window() -> UIWindow? {
        if let window = self.keyWindow {
            return window
        } else if let window = self.windows.first {
            return window
        } else { return nil }
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
