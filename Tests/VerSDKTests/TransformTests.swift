import XCTest
@testable import VerSDK

final class TransformTests: XCTestCase {
    
    // Test convertion Vision Frame to UIKit Frame
    func testTransformRect() {
        let fromVisionRect = CGRect(x: 0.3, y: 0.2, width: 0.5, height: 0.3)
        let toViewRect = CGRect(x: 0, y: 0, width: 428, height: 926)
        let transformResult = fromVisionRect.transform(to: toViewRect)
        let result = CGRect(x: 128.4, y: 463.0, width: 214.0, height: 277.8)
        XCTAssertEqual(result.origin.x, transformResult.origin.x, accuracy: 0.1)
        XCTAssertEqual(result.origin.y, transformResult.origin.y, accuracy: 0.1)
        XCTAssertEqual(result.width, transformResult.width, accuracy: 0.1)
        XCTAssertEqual(result.height, transformResult.height, accuracy: 0.1)
    }
}
