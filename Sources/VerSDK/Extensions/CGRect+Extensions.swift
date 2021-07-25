import CoreGraphics

extension CGRect {
    func transformRect(to viewRect : CGRect) -> CGRect {
        //Convert Vision Frame to UIKit Frame
        var toRect = CGRect()
        toRect.size.width = self.size.width * viewRect.size.width
        toRect.size.height = self.size.height * viewRect.size.height
        toRect.origin.y = (1 - self.origin.y) * viewRect.height
        toRect.origin.y = toRect.origin.y - toRect.size.height
        toRect.origin.x = (1 - self.origin.x) * viewRect.width
        toRect.origin.x = toRect.origin.x - toRect.size.width
        return toRect
    }
}
