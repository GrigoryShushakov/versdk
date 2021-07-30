import UIKit
import AVFoundation

class RecognizeController: BaseViewController<RecognizeVM> {
    
    private let recognizeServicesQueue = DispatchQueue(label: "VerSDK.recognizeServicesQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var boxesLayer = [CAShapeLayer]()
    private let canvasView = BoxesCanvasView()
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        setupPreviewLayer(viewModel.captureService.captureSession)
        let rect = self.view.bounds
        recognizeServicesQueue.async {
            self.viewModel.configure(rect)
        }
    }
    
    private func bindVM() {
        viewModel.didClose.bind { [weak self] value in
            guard let self = self else { return }
            if value { self.close() }
        }
        viewModel.haveFoundText.bind { [weak self] haveFound in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer {
                    self.canvasView.setNeedsLayout()
                }
                self.canvasView.clear()
                self.canvasView.boxes = self.viewModel.boxes
                self.takeShotButton.isEnabled = haveFound ?? false
            }
        }
    }
    
    private func setupPreviewLayer(_ session: AVCaptureSession) {
        // Insert preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize
        previewLayer.frame = view.layer.frame
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    @objc private func close(){
        recognizeServicesQueue.async {
            self.viewModel.stopSession()
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func switchCamera(){
        recognizeServicesQueue.async {
            self.viewModel.switchCameraInput()
        }
    }
    
    @objc private func takeShot() {
        viewModel.takeShot = true
    }
    
    private let switchCameraButton = UIButton().createButton(for: "arrow.triangle.2.circlepath.camera.fill", size: Layout.buttonSize.width / 2)
    private let closeButton = UIButton().createButton(for: "xmark.circle", size: Layout.buttonSize.width / 2)
    private let takeShotButton = UIButton().createButton(for: "largecircle.fill.circle", size: Layout.takeShotButtonSize.width)
    
    private func buildUI(){
        view.addSubview(canvasView)
        view.addSubview(switchCameraButton)
        view.addSubview(closeButton)
        view.addSubview(takeShotButton)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
       
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
}
