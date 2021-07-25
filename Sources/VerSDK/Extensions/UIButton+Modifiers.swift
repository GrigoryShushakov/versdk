import UIKit

extension UIButton {
    func createButton(for systemName: String, size: CGFloat) -> Self {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        setImage(image, for: .normal)
        tintColor = UIColor.white
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
