import XCTest
@testable import n_Weather

final class ImageByCodeHelperTest: XCTestCase {

    func testAllStrormCodesreturnStorm() {
        let stormCodes = [200, 201, 202, 210, 211, 212, 221, 230, 231, 232]

        for code in stormCodes {
            let images = ImagesByCodeHelper.getImageNameByCode(code: code)
            XCTAssertEqual(images, "storm", "Code \(code) should return storm")
        }
    }

    func testAllRainCodesReturnRain() {
        let rainCodes = [300, 301, 302, 310, 311, 312, 313, 314, 321, 500, 501, 502, 503, 504, 511, 520, 521, 522, 531]

        for code in rainCodes {
            let images = ImagesByCodeHelper.getImageNameByCode(code: code)
            XCTAssertEqual(images, "rain", "Code \(code) should return rain")
        }
    }

    func test_allSnowCodes_returnSnow() {
        let snowCodes = [600, 601, 602, 611, 612, 613, 615, 616, 620, 621, 622]

        for code in snowCodes {
            let images = ImagesByCodeHelper.getImageNameByCode(code: code)
            XCTAssertEqual(images, "snow", "Code \(code) should return snow")
        }
    }

    func test_allFogCodes_returnFog() {
        let fogCodes = [701, 711, 721, 731, 741, 751, 761, 762, 771, 781]

        for code in fogCodes {
            let images = ImagesByCodeHelper.getImageNameByCode(code: code)
            XCTAssertEqual(images, "fog", "Code \(code) should return fog")
        }
    }

    func test_allClearCodes_returnClear() {
        let clearCode = 800
        let images = ImagesByCodeHelper.getImageNameByCode(code: clearCode)
        XCTAssertEqual(images, "clearsky", "Code \(clearCode) should return clearsky")
    }
}
