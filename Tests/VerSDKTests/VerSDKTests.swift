    import XCTest
    @testable import VerSDK

    final class VerSDKTests: XCTestCase {
        func testPermissions() {
            let checkService = CheckPermissionsService()
            checkService.checkPermissions { result in
                guard case .success(let value) = result else {
                    return XCTFail("Expected to be a success but got a failure with \(result)")
                }
                XCTAssertNotNil(value)
            }
        }
        func testTransformRect() {
            let fromVisionRect = CGRect(x: 0.3, y: 0.2, width: 0.5, height: 0.3)
            let toViewRect = CGRect(x: 0, y: 0, width: 428, height: 926)
            let transformResult = fromVisionRect.transformRect(toViewRect: toViewRect)
            let result = CGRect(x: 85.59999999999997, y: 463.00000000000006, width: 214.0, height: 277.8)
            XCTAssertEqual(result, transformResult)
        }
    }
