import Foundation
@testable import n_Weather

extension LastLocation{
    static func mock() -> LastLocation {
        LastLocation(lon: 54.12,
                     lat: 34.32,
                     cityName: "Moscow",
                     updatedAt: Date())
    }
}
