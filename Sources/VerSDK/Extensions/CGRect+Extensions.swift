import CoreGraphics
import Vision

extension CGRect {
    // Transform Vision rect to UIKit
    func transform(to viewRect: CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        return VNImageRectForNormalizedRect(self.applying(transform), Int(viewRect.width), Int(viewRect.height))
    }
    // Approximate method for check head in center of screen
    func isCenterPosition(in frame: CGRect, with deviation: CGFloat) -> Bool {
        let verticalOccurrence = abs((frame.midY - self.midY) / frame.midY) < deviation
        let horizontalOccurence = abs((frame.midX - self.midX) / frame.midX) < deviation
        return verticalOccurrence && horizontalOccurence
    }
}
