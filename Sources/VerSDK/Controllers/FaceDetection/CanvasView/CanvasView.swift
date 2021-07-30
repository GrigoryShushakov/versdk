import UIKit

class CanvasView: UIView {
    var faceRect: CGRect = .zero
    var faceColor: UIColor = .red
    var rightEye: [CGPoint] = []
    var leftEye: [CGPoint] = []
    
    func clear() {
        faceRect = .zero
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        defer {
            context.restoreGState()
        }
        
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: faceRect)
        faceColor.setStroke()
        UIColor.clear.setFill()
        path.lineWidth = 1
        
        context.addPath(path.cgPath)
        context.strokePath()
        
        UIColor.red.setStroke()
        
        if !rightEye.isEmpty {
            context.addLines(between: rightEye)
            context.closePath()
            context.strokePath()
        }
        
        if !leftEye.isEmpty {
            context.addLines(between: leftEye)
            context.closePath()
            context.strokePath()
        }
    }
}
