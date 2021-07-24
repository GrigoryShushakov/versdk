import UIKit
import AVFoundation
import Vision

public final class RecognizeVM: NSObject {
    var callback: ((Result<[String], Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    let permissionService: CheckPermissionServiceProtocol
    private var requests = [VNRequest]()
    
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    
    init(callback: @escaping ((Result<[String], Error>) -> Void),
         captureService: CaptureSessionServiceProtocol,
         permissionService: CheckPermissionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
        self.permissionService = permissionService
    }
    
    public func configure(_ view: UIView) {
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
    
    private func startSession(_ view: UIView) {
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
    
    public func stopSession() {
        captureService.stopSession()
    }
    
    public func switchCameraInput() {
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
        guard !result.isEmpty else { return }
        callback(.success(result))
    }
}

extension RecognizeVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
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
