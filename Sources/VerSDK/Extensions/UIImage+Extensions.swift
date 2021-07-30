import UIKit

extension UIImageView {
    func createImageView(for systemName: String, size: CGFloat) -> Self {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        image = UIImage(systemName: systemName, withConfiguration: config)
        tintColor = UIColor.red
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
