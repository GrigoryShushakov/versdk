import UIKit
import AVFoundation
import Vision

final class RecognizeVM: NSObject {
    var callback: ((Result<[String], Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    let permissionService: CheckPermissionServiceProtocol
    
    private var requests = [VNRequest]()
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFoundText: SimpleObservable<Bool?> = SimpleObservable(nil)
    var takeShot = false
    
    init(callback: @escaping ((Result<[String], Error>) -> Void),
         captureService: CaptureSessionServiceProtocol,
         permissionService: CheckPermissionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
        self.permissionService = permissionService
    }
    
    func configure(_ view: UIView) {
        permissionService.checkPermissions { [weak self] result in
            guard let self = self else { return }
            
            if case let .failure(error) = result {
                self.callback(.failure(error))
                self.didClose.value = true
            } else {
                self.startSession(view)
            }
        }
    }
    
    func startSession(_ view: UIView) {
        captureService.startSession(delegate: self,
                                    view: view,
                                    position: .back,
                                    completion: { [weak self] result in
            guard let self = self else { return }
                                            
            if case let .failure(error) = result {
                self.callback(.failure(error))
                self.didClose.value = true
            }
        })

        setupVision()
    }
    
    func stopSession() {
        captureService.stopSession()
    }
    
    func switchCameraInput() {
        captureService.switchCameraInput()
    }
    
    private func setupVision() {
        let textRequest = VNRecognizeTextRequest(completionHandler: self.textDetectionHandler)
        textRequest.recognitionLevel = .accurate
        textRequest.recognitionLanguages = ["ee_EE", "en_US"]
        self.requests = [textRequest]
    }
    
    private func textDetectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        let result = observations.compactMap { $0.topCandidates(1).first?.string }
        haveFoundText.value = !result.isEmpty
        guard !result.isEmpty else { return }
        if takeShot {
            takeShot = false
            callback(.success(result))
            didClose.value = true
        }
    }
}

extension RecognizeVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .up,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
