import CoreGraphics

extension CGRect {
    public func transformRect(toViewRect : CGRect) -> CGRect {
        //Convert Vision Frame to UIKit Frame
        var toRect = CGRect()
        toRect.size.width = self.size.width * toViewRect.size.width
        toRect.size.height = self.size.height * toViewRect.size.height
        toRect.origin.y = (1 - self.origin.y) * toViewRect.height
        toRect.origin.y = toRect.origin.y - toRect.size.height
        toRect.origin.x = (1 - self.origin.x) * toViewRect.width
        toRect.origin.x = toRect.origin.x - toRect.size.width
        return toRect
    }
}
