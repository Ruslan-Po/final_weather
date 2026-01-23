import Foundation
@testable import n_Weather

class MockCitySearchService: CitySearchServiceProtocol {
    var onResultsUpdated: (([String]) -> Void)?
    var onError: ((Error) -> Void)?
    
    var searchWasCalled = false
    var lastSearchQuery: String?
    var cancelWasCalled = false
    
    func search(query: String) {
        searchWasCalled = true
        lastSearchQuery = query
    }
    
    func cancelSearch() {
        cancelWasCalled = true
    }
}



