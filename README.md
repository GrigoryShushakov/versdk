[![Swift 5.1](https://img.shields.io/badge/swift-5.1-red.svg?style=flat)](https://developer.apple.com/swift)

# VerSDK

**VerSDK** is a Framework helped with recognition text in documents and suitable take verification selfie. The SDK calls the user interface for photography and returns the result of text recognition or face detection.


## Need Help?

Please, use [GitHub Issues](https://github.com/GrigoryShushakov/versdk/issues) for reporting a bug or requesting a new feature.


## Examples

[Sample App](https://github.com/GrigoryShushakov/client-app-swift)


## Installation

VerSDK can be installed with [Swift Package Manager](https://swift.org/package-manager/).
### Swift Package Manager (Xcode 12 or higher)

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/GrigoryShushakov/versdk.git`) and click **Next**.
3. For **Rules**, select **Version (Up to Next Major)** and click **Next**.
4. Click **Finish**.

[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)


## Usage

1. For text recognition please call `textRecognition` sdk method in your application.
Method returns array of recognized strings or Error with localized description.

```
VerSDK.shared.textRecognition { result in
    switch result {
    case .success(let prediction):
        // Text recognition result - [String]
    case .failure(let error):
        showError(error)
    }
}
```
2. For face detection please call `faceDetection` sdk method in your application.
Method returns UIImage or Error with localized description.

```
VerSDK.shared.faceDetection() { result in
    switch result {
    case .success(let image):
        // Face detection image - UIImage
    case .failure(let error):
        showError(error)
    }
}
```

## Adding permissions

VerSDK requires camera permissions for capturing photos. Your application is responsible to describe the reason why camera is used. You must add `NSCameraUsageDescription` value to info.plist of your application with the explanation of the usage.


## Requirements

- iOS 13.0+
- Swift 5.1+ (Library is written in Swift 5.3)


## Author

Grigory Shushakov


## License

**VerSDK** is available under the MIT license. See the LICENSE file for more info.
