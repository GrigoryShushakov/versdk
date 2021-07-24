import UIKit

public class FaceDetectionController: BaseViewController<FaceDetectionVM> {
    
    var faceRectangle: UIView?
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        viewModel.configure(view)
    }
    
    private func buildUI(){
        view.addSubview(switchCameraButton)
        view.addSubview(closeButton)
       
        NSLayoutConstraint.activate([
            switchCameraButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            switchCameraButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            switchCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            switchCameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.spacing)
        ])
       
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func bindVM() {
        viewModel.didClose.bind { [weak self] value in
            if value { self?.close() }
        }
        viewModel.haveFaceRect.bind { [weak self] rect in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.faceRectangle != nil { self.faceRectangle?.removeFromSuperview() }
                guard rect != nil else { return }
                self.faceRectangle = self.viewModel.createBoxView(withColor: UIColor.red)
                self.faceRectangle!.frame = self.viewModel.transformRect(fromRect: rect!, toViewRect: self.view)
                self.view.addSubview(self.faceRectangle!)
            }
        }
    }
    
    @objc private func close(){
        viewModel.stopSession()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func switchCamera(){
        viewModel.switchCameraInput()
    }
    
    private let switchCameraButton : UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton : UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark.circle")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
}
