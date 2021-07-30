import CoreGraphics
import Vision

extension CGPoint {
    // Transform Vision point to UIKit
    func transform(to view: CGRect) -> CGPoint {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let vnPoint = VNImagePointForNormalizedPoint(self.applying(transform), Int(view.width), Int(view.height))
        return CGPoint(x: vnPoint.x + view.origin.x, y: vnPoint.y + view.origin.y)
    }
}
