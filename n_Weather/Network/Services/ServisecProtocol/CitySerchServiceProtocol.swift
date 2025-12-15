import Foundation

protocol CitySearchServiceProtocol: AnyObject {
    var onResultsUpdated: (([String]) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func search(query: String)
    func cancelSearch()
}
