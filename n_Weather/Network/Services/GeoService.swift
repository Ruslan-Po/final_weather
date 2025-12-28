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
    private let syncQueue = DispatchQueue(label: "syncQueue")
    private let completionQueue: DispatchQueue
    
    init(completionQueue: DispatchQueue = .main) {
        self.completionQueue = completionQueue
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        syncQueue.async { [weak self] in
            guard let self = self else { return }

            self.locationCompletion = completion

            DispatchQueue.main.async {
                switch self.locationManager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationManager.requestLocation()
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                case .denied, .restricted:
                    self.complete(with: .failure(LocationError.permissionDenied))
                @unknown default:
                    self.complete(with: .failure(LocationError.unknown))
                }
            }
        }
    }

    func getCoordinates(for cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let normalizedName = normalizeCityName(cityName)
        geocoder.geocodeAddressString(normalizedName) { [weak self] placemarks, error in
            guard let self = self else { return }
            self.completionQueue.async {
                if let error = error {
                    if let clError = error as? CLError {
                        switch clError.code {
                        case .geocodeFoundNoResult, .geocodeFoundPartialResult:
                            completion(.failure(LocationError.cityNotFound))
                        case .network:
                            completion(.failure(clError))
                        default:
                            completion(.failure(clError))
                        }
                    } else {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    completion(.failure(LocationError.cityNotFound))
                    return
                }
                completion(.success(coordinate))
            }
        }
    }
    
    private func normalizeCityName(_ name: String) -> String {
        let replacements = [
            "Москва, Россия": "Moscow, Russia",
            "Москва": "Moscow"
        ]
        return replacements[name] ?? name
    }

    func getCityName(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            self.completionQueue.async {
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

    private func complete(with result: Result<CLLocationCoordinate2D, Error>) {
        syncQueue.async { [weak self] in
            guard let self = self,
                  let completion = self.locationCompletion else { return }
            
            self.locationCompletion = nil
            
            self.completionQueue.async {
                completion(result)
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        complete(with: .success(location.coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        complete(with: .failure(error))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}
