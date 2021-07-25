import UIKit

class OvalView: UIView {
    override func draw(_ rect: CGRect) {
        let ovalPath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = ovalPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 1.5
        layer.addSublayer(shapeLayer)
    }
}
