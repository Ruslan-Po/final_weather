import Foundation
@testable import n_Weather

final class MockLocationStorage: LocationStorageProtocol {
    private var savedLocation: LastLocation?

    var saveWasCalled = false
    var saveCallCount = 0
    var getWasCalled = false
    var getCallCount = 0
    var lastSavedLocation: LastLocation?

    func save(_ location: LastLocation) {
        saveWasCalled = true
        saveCallCount += 1
        lastSavedLocation = location
        savedLocation = location
    }

    func get() -> LastLocation? {
        getWasCalled = true
        getCallCount += 1
        return savedLocation
    }

    func setSavedLocation(_ location: LastLocation) {
        savedLocation = location
    }

    func clear() {
        savedLocation = nil
    }

    func reset() {
        saveWasCalled = false
        saveCallCount = 0
        getWasCalled = false
        getCallCount = 0
        lastSavedLocation = nil
        savedLocation = nil
    }
}
