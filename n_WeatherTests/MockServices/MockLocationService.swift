import CoreLocation
@testable import n_Weather

final class MockLocationService: LocationServiceProtocol {

    var shouldReturnError = false
    var coordinatesToReturn: CLLocationCoordinate2D?
    var cityNameToReturn: String?
    var errorToReturn: Error = LocationError.unknown

    var requestLocationPermissionWasCalled = false
    var getCurrentLocationWasCalled = false
    var getCurrentLocationCallCount = 0
    var getCoordinatesWasCalled = false
    var getCoordinatesCallCount = 0
    var getCityNameWasCalled = false
    var getCityNameCallCount = 0

    var lastSearchedCityName: String?
    var lastCoordinatesForCityName: CLLocationCoordinate2D?

    func requestLocationPermission() {
        requestLocationPermissionWasCalled = true
    }

    func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        getCurrentLocationWasCalled = true
        getCurrentLocationCallCount += 1

        if shouldReturnError {
            completion(.failure(errorToReturn))
        } else if let coordinates = coordinatesToReturn {
            completion(.success(coordinates))
        }
    }

    func getCoordinates(for cityName: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        getCoordinatesWasCalled = true
        getCoordinatesCallCount += 1
        lastSearchedCityName = cityName

        if shouldReturnError {
            completion(.failure(errorToReturn))
        } else if let coordinates = coordinatesToReturn {
            completion(.success(coordinates))
        }
    }

    func getCityName(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        getCityNameWasCalled = true
        getCityNameCallCount += 1
        lastCoordinatesForCityName = coordinates

        if shouldReturnError {
            completion(.failure(errorToReturn))
        } else if let cityName = cityNameToReturn {
            completion(.success(cityName))
        }
    }

    func setMockCoordinates(latitude: Double, longitude: Double) {
        coordinatesToReturn = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func setMockError(_ error: LocationError) {
        shouldReturnError = true
        errorToReturn = error
    }

    func reset() {
        requestLocationPermissionWasCalled = false
        getCurrentLocationWasCalled = false
        getCurrentLocationCallCount = 0
        getCoordinatesWasCalled = false
        getCoordinatesCallCount = 0
        getCityNameWasCalled = false
        getCityNameCallCount = 0
        lastSearchedCityName = nil
        lastCoordinatesForCityName = nil
        shouldReturnError = false
        coordinatesToReturn = nil
        cityNameToReturn = nil
        errorToReturn = LocationError.unknown
    }
}
