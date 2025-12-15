import MapKit

final class CitySearchService: NSObject, CitySearchServiceProtocol {
    var onResultsUpdated: (([String]) -> Void)?
    var onError: ((any Error) -> Void)?

    private let completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func search(query: String) {
        completer.queryFragment = query
    }
    
    func cancelSearch() {
        completer.cancel()
    }
}

extension CitySearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter){
        let cities = completer.results
                .filter { result in
                    !result.title.contains("Road") &&
                    !result.title.contains("Drive") &&
                    !result.title.contains("Street") &&
                    !result.title.contains("Avenue")
                }
                .prefix(5)
                .map { result in
                    if result.subtitle.isEmpty {
                        return result.title
                    } else {
                        return "\(result.title), \(result.subtitle)"
                    }
                }
            onResultsUpdated?(Array(cities))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error){
        if(error as NSError).code == MKError.placemarkNotFound.rawValue {
            onResultsUpdated?([])
            return
        }
        onError?(error)
    }
}
