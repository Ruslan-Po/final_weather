import XCTest
@testable import n_Weather

class MockLocationStorage: LocationStorageProtocol {
    
    var locationToReturn: LastLocation? 
    
    var getCalled = false
    var saveCalled = false
    var clearCalled = false
    
    func get() -> LastLocation? {
        getCalled = true
        return locationToReturn
    }
    
    func clear() {
        clearCalled = true
        locationToReturn = nil
    }
    
    func save(_ location: LastLocation) {
        saveCalled = true
        locationToReturn = location
    }
    
}
