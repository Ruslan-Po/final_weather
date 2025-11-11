import CoreLocation
import MapKit

enum LocationError: LocalizedError {
    case permissionDenied
    case cityNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission Denied"
        case .cityNotFound:
            return "City not found"
        case .unknown:
            return "Unknown error"
        }
    }
}


protocol LocationServiceProtocol {
    func requestLocationPermission()
    func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    func getCoordinates(for cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    func getCityName(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void)
}

class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationCompletion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        locationCompletion = completion
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            completion(.failure(LocationError.permissionDenied))
        @unknown default:
            completion(.failure(LocationError.unknown))
        }
    }
    
    func getCoordinates(for cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                completion(.failure(LocationError.cityNotFound))
                return
            }
            
            completion(.success(coordinate))
        }
    }
    
    func getCityName(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let cityName = placemarks?.first?.locality else {
                completion(.failure(LocationError.cityNotFound))
                return
            }
            
            completion(.success(cityName))
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationCompletion?(.success(location.coordinate))
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(.failure(error))
        locationCompletion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}


