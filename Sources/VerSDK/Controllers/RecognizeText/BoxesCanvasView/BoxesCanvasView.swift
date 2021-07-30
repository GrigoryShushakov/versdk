import UIKit

class BoxesCanvasView: UIView {
    var boxes: [CGRect] = []
    
    func clear() {
        boxes = []
        
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
        
        UIColor.green.setStroke()
        UIColor.clear.setFill()
        context.setLineWidth(0.5)
        
        for box in boxes {
            context.addRect(box)
            context.strokePath()
        }
    }
}
