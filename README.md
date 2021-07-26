[![Swift 5.3](https://img.shields.io/badge/swift-4.2-red.svg?style=flat)](https://developer.apple.com/swift)

# VerSDK

**VerSDK** is a Framework helped with recognition text in Documents and suitable take verification selfie.


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

### CocoaPods

To install it, add the following line to your Podfile:

```ruby
pod 'VerSDK'
```
[Adding Pods to an Xcode project](https://guides.cocoapods.org/using/using-cocoapods.html)


## Usage
1. Text recognition

```
VerSDK.shared.textRecognition { [weak self] result in
    guard let self = self else { return }
    switch result {
    case .success(let prediction):
        // Text recognition result - [String]
    case .failure(let error):
        self.showError(error)
    }
}
```
2. Face detection

```
VerSDK.shared.faceDetection() { [weak self] result in
    guard let self = self else { return }
    switch result {
    case .success(let image):
        // Face detection image - UIImage
    case .failure(let error):
        self.showError(error)
    }
}
```


## Requirements

- iOS 13.0+
- Swift 4+ (Library is written in Swift 5.3)


## Author

Grigory Shushakov


## License

**VerSDK** is available under the MIT license. See the LICENSE file for more info.
