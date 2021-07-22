import UIKit

public class VerSDK {
    public func run() {
        guard let topController = UIApplication.shared.window()?.topViewController() else { return }
        let controller = Controller(nibName: nil, bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        topController.present(controller, animated: true, completion: nil)
    }
    public static let shared = VerSDK()
}

public class Controller: UIViewController {
   
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
    }
}
