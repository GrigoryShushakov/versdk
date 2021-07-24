import UIKit

public class RecognizeController: BaseViewController<RecognizeVM> {
    
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
