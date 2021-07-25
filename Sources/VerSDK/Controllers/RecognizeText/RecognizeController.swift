import UIKit

class RecognizeController: BaseViewController<RecognizeVM> {
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        viewModel.configure(view)
    }
    
    private func buildUI(){
        view.addSubview(switchCameraButton)
        view.addSubview(closeButton)
        view.addSubview(takeShotButton)
       
        NSLayoutConstraint.activate([
            switchCameraButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            switchCameraButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            switchCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            switchCameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.spacing),
            takeShotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.takeShotButtonBottom),
            takeShotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takeShotButton.widthAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.width),
            takeShotButton.heightAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.height)
        ])
       
        switchCameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        takeShotButton.addTarget(self, action: #selector(takeShot), for: .touchUpInside)
        takeShotButton.isEnabled = false
    }
    
    private func bindVM() {
        viewModel.didClose.bind { [weak self] value in
            if value { self?.close() }
        }
        viewModel.haveFoundText.bind { [weak self] value in
            DispatchQueue.main.async {
                self?.takeShotButton.isEnabled = value ?? false
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
    
    @objc private func takeShot() {
        viewModel.takeShot = true
    }
    
    private let switchCameraButton = UIButton().createButton(for: "arrow.triangle.2.circlepath.camera.fill", size: Layout.buttonSize.width / 2)
    private let closeButton = UIButton().createButton(for: "xmark.circle", size: Layout.buttonSize.width / 2)
    private let takeShotButton = UIButton().createButton(for: "largecircle.fill.circle", size: Layout.takeShotButtonSize.width)
}
