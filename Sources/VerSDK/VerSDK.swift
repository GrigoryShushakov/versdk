import UIKit

public class VerSDK {
    public static let shared = VerSDK()
    
    public func textRecognition(_ callback: @escaping (Result<[String], Error>) -> Void) {
        guard let topController = UIApplication.shared.window()?.topViewController() else { return }
        let viewModel = RecognizeVM(callback: callback,
                                    captureService: CaptureSessionService())
        let controller = RecognizeController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        topController.present(controller, animated: true, completion: nil)
    }
    
    public func faceDetection(_ callback: @escaping (Result<UIImage, Error>) -> Void) {
        guard let topController = UIApplication.shared.window()?.topViewController() else { return }
        let viewModel = FaceDetectionVM(callback: callback,
                                        captureService: CaptureSessionService())
        let controller = FaceDetectionController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        topController.present(controller, animated: true, completion: nil)
    }
}
