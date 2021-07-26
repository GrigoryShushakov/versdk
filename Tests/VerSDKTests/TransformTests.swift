import XCTest
@testable import VerSDK

final class VerSDKTests: XCTestCase {
    func testTransformRect() {
        let fromVisionRect = CGRect(x: 0.3, y: 0.2, width: 0.5, height: 0.3)
        let toViewRect = CGRect(x: 0, y: 0, width: 428, height: 926)
        let transformResult = fromVisionRect.transformRect(to: toViewRect)
        let result = CGRect(x: 85.599, y: 463.000, width: 214.0, height: 277.8)
        XCTAssertEqual(result.origin.x, transformResult.origin.x, accuracy: 0.001)
        XCTAssertEqual(result.origin.y, transformResult.origin.y, accuracy: 0.001)
        XCTAssertEqual(result.width, transformResult.width, accuracy: 0.001)
        XCTAssertEqual(result.height, transformResult.height, accuracy: 0.001)
    }
}
