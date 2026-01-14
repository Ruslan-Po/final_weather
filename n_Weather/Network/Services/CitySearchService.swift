import MapKit
import CoreLocation

final class CitySearchService: NSObject, CitySearchServiceProtocol {
    var onResultsUpdated: (([String]) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let completer = MKLocalSearchCompleter()
    private let englishLocale = Locale(identifier: "en_US")
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }
    
    func search(query: String) {
        guard query.count >= 2 else {
            onResultsUpdated?([])
            return
        }
        completer.queryFragment = query
    }
    
    func cancelSearch() {
        completer.cancel()
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension CitySearchService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = Array(completer.results.prefix(5))
        
        print("Found \(results.count) results")
        
        guard !results.isEmpty else {
            onResultsUpdated?([])
            return
        }
        
        processResultsSequentially(results: results, index: 0, accumulated: [])
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
    }
    
    // MARK: - Private
    
    private func processResultsSequentially(
        results: [MKLocalSearchCompletion],
        index: Int,
        accumulated: [String]
    ) {

        guard index < results.count else {
            DispatchQueue.main.async {
                var seen = Set<String>()
                let unique = accumulated.filter { seen.insert($0).inserted }
                print("English names: \(unique)")
                self.onResultsUpdated?(unique)
            }
            return
        }
        
        let result = results[index]
        let request = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, _ in
            guard let self = self else { return }
            
            guard let mapItem = response?.mapItems.first else {
                self.processResultsSequentially(
                    results: results,
                    index: index + 1,
                    accumulated: accumulated
                )
                return
            }
            
            let coordinate = mapItem.placemark.coordinate
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            

            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(
                location,
                preferredLocale: self.englishLocale
            ) { [weak self] placemarks, _ in
                guard let self = self else { return }
                
                var newAccumulated = accumulated
                
                if let placemark = placemarks?.first,
                   let city = placemark.locality {
                    let name = placemark.country != nil
                        ? "\(city), \(placemark.country!)"
                        : city
                    newAccumulated.append(name)
                }
                
                self.processResultsSequentially(
                    results: results,
                    index: index + 1,
                    accumulated: newAccumulated
                )
            }
        }
    }
}
