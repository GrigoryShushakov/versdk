import UIKit
import AVFoundation

class FaceDetectionController: BaseViewController<FaceDetectionVM> {
    
    private let faceDetectionServicesQueue = DispatchQueue(label: "VerSDK.faceDetectionServicesQueue", qos: .userInitiated)
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private let canvasView = CanvasView()
    
    override func configure() {
        super.configure()
        buildUI()
        bindVM()
        setupPreviewLayer(viewModel.captureService.captureSession)
        let rect = self.view.bounds
        faceDetectionServicesQueue.async {
            self.viewModel.configure(rect)
        }
    }
    
    private func bindVM() {
        viewModel.didClose.bind { [weak self] value in
            guard let self = self else { return }
            if value { self.close() }
        }
        viewModel.haveFaceRect.bind { [weak self] rect in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer {
                    self.canvasView.setNeedsDisplay()
                }
                self.canvasView.clear()
                guard rect != nil else { return }

                let allIsGood = self.viewModel.isCenter.value
                    && self.viewModel.eyesIsOpen.value
                    && self.viewModel.notRolled.value
                    && self.viewModel.notYawed.value
                self.canvasView.faceRect = rect!
                self.canvasView.faceColor = allIsGood ? UIColor.green : UIColor.red
                self.canvasView.rightEye = self.viewModel.rightEyePoints
                self.canvasView.leftEye = self.viewModel.leftEyePoints
                self.takeShotButton.isEnabled = allIsGood
            }
        }
        viewModel.isCenter.bind { [weak self] isCenter in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.centerImageView.tintColor = isCenter ? UIColor.green : UIColor.red
            }
        }
        viewModel.eyesIsOpen.bind { [weak self] isOpen in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.eyesImageView.tintColor = isOpen ? UIColor.green : UIColor.red
            }
        }
        viewModel.notRolled.bind { [weak self] notRolled in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.notRolledImageView.tintColor = notRolled ? UIColor.green : UIColor.red
            }
        }
        viewModel.notYawed.bind { [weak self] notYawed in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.notYawedImageView.tintColor = notYawed ? UIColor.green : UIColor.red
            }
        }
    }
    
    private func setupPreviewLayer(_ session: AVCaptureSession) {
        // Insert preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    @objc private func close() {
        self.viewModel.stopSession()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func takeShot() {
        viewModel.takeShot = true
    }
    
    private let centerImageView = UIImageView().createImageView(for: "person.fill.viewfinder", size: Layout.buttonSize.width)
    private let eyesImageView = UIImageView().createImageView(for: "eyes", size: Layout.buttonSize.width)
    private let notRolledImageView = UIImageView().createImageView(for: "person.fill.turn.left", size: Layout.buttonSize.width)
    private let notYawedImageView = UIImageView().createImageView(for: "person.fill.and.arrow.left.and.arrow.right", size: Layout.buttonSize.width)
    private let closeButton = UIButton().createButton(for: "xmark.circle", size: Layout.buttonSize.width / 2)
    private let takeShotButton = UIButton().createButton(for: "largecircle.fill.circle", size: Layout.takeShotButtonSize.width)
    
    private func buildUI(){
        view.addSubview(canvasView)
        view.addSubview(centerImageView)
        view.addSubview(eyesImageView)
        view.addSubview(notRolledImageView)
        view.addSubview(notYawedImageView)
        view.addSubview(closeButton)
        view.addSubview(takeShotButton)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .clear
       
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            centerImageView.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            centerImageView.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            centerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            centerImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            
            eyesImageView.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            eyesImageView.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            eyesImageView.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: Layout.spacing),
            eyesImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            
            notRolledImageView.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            notRolledImageView.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            notRolledImageView.topAnchor.constraint(equalTo: eyesImageView.bottomAnchor, constant: Layout.spacing),
            notRolledImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            
            notYawedImageView.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            notYawedImageView.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            notYawedImageView.topAnchor.constraint(equalTo: notRolledImageView.bottomAnchor, constant: Layout.spacing),
            notYawedImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.spacing),
            
            closeButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.offset),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.spacing),
            
            takeShotButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.takeShotButtonBottom),
            takeShotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takeShotButton.widthAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.width),
            takeShotButton.heightAnchor.constraint(equalToConstant: Layout.takeShotButtonSize.height)
        ])
       
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        takeShotButton.addTarget(self, action: #selector(takeShot), for: .touchUpInside)
        takeShotButton.isEnabled = false
    }
}
