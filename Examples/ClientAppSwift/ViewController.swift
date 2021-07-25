import UIKit
import VerSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        buildUI()
    }
    
    private func buildUI() {
        view.addSubview(textRecognitionButton)
        view.addSubview(faceDetectionButton)
        textRecognitionButton.translatesAutoresizingMaskIntoConstraints = false
        textRecognitionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textRecognitionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        faceDetectionButton.translatesAutoresizingMaskIntoConstraints = false
        faceDetectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        faceDetectionButton.topAnchor.constraint(equalTo: textRecognitionButton.bottomAnchor, constant: 32).isActive = true
    }
    
    @objc private func startTextRecognition() {
        VerSDK.shared.textRecognition { result in
            switch result {
            case .success(let prediction):
                print(prediction)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func startFaceDetection() {
        VerSDK.shared.faceDetection() { result in
            switch result {
            case .success(let prediction):
                print(prediction)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    let textRecognitionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Text Recognition", for: .normal)
        button.addTarget(self, action: #selector(startTextRecognition), for: .touchUpInside)
        return button
    }()
    
    let faceDetectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Face Detection", for: .normal)
        button.addTarget(self, action: #selector(startFaceDetection), for: .touchUpInside)
        return button
    }()
}

