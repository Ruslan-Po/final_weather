import CoreLocation

final class CitySearchService: CitySearchServiceProtocol {
    var onResultsUpdated: (([String]) -> Void)?
    var onError: ((any Error) -> Void)?
    
    private let geocoder = CLGeocoder()
    private let locale = Locale(identifier: "en_US")
    
    func search(query: String) {
        geocoder.cancelGeocode()
        
        geocoder.geocodeAddressString(
            query,
            in: nil,
            preferredLocale: locale
        ) { [weak self] placemarks, error in
            
            if let error = error {
                let nsError = error as NSError
                if nsError.domain == kCLErrorDomain &&
                   nsError.code == CLError.geocodeFoundNoResult.rawValue {
                    self?.onResultsUpdated?([])
                    return
                }
                self?.onError?(error)
                return
            }
            
            var seen = Set<String>()
            let cities = placemarks?
                .compactMap { placemark -> String? in
                    guard let city = placemark.locality else { return nil }
                    let result = placemark.country != nil
                        ? "\(city), \(placemark.country!)"
                        : city
                    return seen.insert(result).inserted ? result : nil
                }
                .prefix(5)
            
            self?.onResultsUpdated?(Array(cities ?? []))
        }
    }
    
    func cancelSearch() {
        geocoder.cancelGeocode()
    }
}
