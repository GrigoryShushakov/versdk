import CoreGraphics
import Vision

extension CGRect {
    // Transform Vision rect to UIKit
    func transform(to viewRect :CGRect) -> CGRect {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        return VNImageRectForNormalizedRect(self.applying(transform), Int(viewRect.width), Int(viewRect.height))
    }
}
