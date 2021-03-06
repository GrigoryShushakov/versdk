import UIKit
import AVFoundation

protocol CaptureSessionServiceProtocol {
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      position: AVCaptureDevice.Position,
                      completion: ((Result<Void,Error>) -> Void))
    func stopSession()
    func switchCameraInput()
    var captureSession: AVCaptureSession { get }
}

final class CaptureSessionService: CaptureSessionServiceProtocol {
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    var backInput: AVCaptureInput!
    var frontInput: AVCaptureInput!
    var videoOutput: AVCaptureVideoDataOutput!
    var backCameraOn = true
    
    func stopSession() {
        captureSession.stopRunning()
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
    }
    
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      position: AVCaptureDevice.Position,
                      completion: (Result<Void, Error>) -> Void) {
        
        // Start configuration
        captureSession.beginConfiguration()
        // Setup inputs
        do {
            try self.setupInputs(captureSession, position)
        } catch {
            completion(.failure(error))
        }
        // Setup output
        do {
            try self.setupOutput(captureSession, delegate)
        } catch {
            completion(.failure(error))
        }
        // Commit configuration
        captureSession.commitConfiguration()
        // Start running session
        captureSession.startRunning()
    }
    
    private func searchCamera(deviceTypes: [AVCaptureDevice.DeviceType],
                              mediaType: AVMediaType,
                              position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                mediaType: mediaType,
                                                position: position).devices.first
    }
    
    private func setupInputs(_ session: AVCaptureSession, _ position: AVCaptureDevice.Position) throws {
        // Get back camera
        guard let backCamera = searchCamera(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
                                            mediaType: .video,
                                            position: .back)  else {
            throw AVSessionError.deviceInitFailure("Back camera")
        }
        // Get front camera
        guard let frontCamera = searchCamera(deviceTypes: [.builtInWideAngleCamera],
                                     mediaType: .video,
                                     position: .front)  else {
            throw AVSessionError.deviceInitFailure("Front camera")
        }
        // Setup input data from devices
        do {
            backInput = try AVCaptureDeviceInput(device: backCamera)
            frontInput = try AVCaptureDeviceInput(device: frontCamera)
            // Set zoom and autofocus to help focus on very small text.
            try backCamera.lockForConfiguration()
            backCamera.videoZoomFactor = 2
            backCamera.autoFocusRangeRestriction = .near
            backCamera.unlockForConfiguration()
        } catch {
            throw AVSessionError.deviceInputInitFailure(error.localizedDescription)
        }
        // Check inputs for session
        guard session.canAddInput(backInput) else {
            throw AVSessionError.addInputToSessionFailure("Back camera")
        }

        guard session.canAddInput(frontInput) else {
            throw AVSessionError.addInputToSessionFailure("Front camera")
        }
        // Connect back camera input to session
        if position == .back {
            session.addInput(backInput)
        } else {
            session.addInput(frontInput)
            backCameraOn = false
        }
    }
    
    private func setupOutput(_ session: AVCaptureSession, _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate) throws {
        // Create session output
        videoOutput = AVCaptureVideoDataOutput()
        let callbackQueue = DispatchQueue(label: "callbackQueue", qos: .userInteractive)
        // Setup session output delegate
        videoOutput.setSampleBufferDelegate(delegate, queue: callbackQueue)
        
        guard session.canAddOutput(videoOutput)  else {
            throw AVSessionError.addOutputToSessionFailure
        }
        // Add output to session
        session.addOutput(videoOutput)
        // Only portrait mode in use
        videoOutput.connections.first?.videoOrientation = .portrait
        // Mirror the video stream for front camera
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
    }
    
    func switchCameraInput() {
        // Reconfigure the input
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        // Deal with the connection again for portrait mode
        videoOutput.connections.first?.videoOrientation = .portrait
        // Mirror the video stream for front camera
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        // Commit config
        captureSession.commitConfiguration()
    }
}
