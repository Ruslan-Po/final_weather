import XCTest
@testable import n_Weather

final class DateTimeHelperTest: XCTestCase {

    override func setUp() {
        super.setUp()
        DateTimeHelper.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.hoursFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.dateFormatter.locale = Locale(identifier: "en_US")
    }

    func test_formateTime_fromUnixTimeStamp_returnCorrectTime() {
        let timeStamp = 1764679055
        let expectedTime = "12:37"

        let formattedTime = DateTimeHelper.formatTime(from: timeStamp)

        XCTAssertEqual(formattedTime, expectedTime, "Formate of time should be equal")
    }

    func test_formattedDate_fromUnixTimeStamp_returnCorrectDate() {
        let timeStamp = 1764679055
        let expectedDate = "2 Dec"

        let formattedDate = DateTimeHelper.formatDate(from: timeStamp)

        XCTAssertEqual(formattedDate, expectedDate)
    }
}
