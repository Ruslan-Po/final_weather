import Foundation

protocol WeatherRepositoryProtocol {
    var currentWeather: WeatherModel? {get}
    func fetchCurrentWeather(lon: Double, lat: Double, forceRefresh: Bool, completion: @escaping (Result<WeatherModel, Error>) -> Void)
    
}

class WeatherRepository: WeatherRepositoryProtocol {
    private var client: WeatherClientProtocol
    private var cachedWeather: WeatherModel?
    private var cachedCoord: (lon: Double, lat: Double)?
    private var lastFetchTime: Date?
    private let cacheDuration: TimeInterval = 300

    init(client: WeatherClientProtocol) {
            self.client = client
        }

    var currentWeather: WeatherModel? {
        return cachedWeather
    }
    
    func fetchCurrentWeather(lon: Double, lat: Double, forceRefresh: Bool = false, completion: @escaping (Result<WeatherModel, any Error>) -> Void) {

        if !forceRefresh,
            let cached = cachedWeather,
            isCacheValid(for: lon, lat: lat) {
            completion(.success(cached))
            return
        }
        
        client.fetch(lon: lon, lat: lat) { [weak self] result in
            if case .success(let weather) = result {
                self?.cachedWeather = weather
                self?.cachedCoord = (lon, lat)
                self?.lastFetchTime = Date()
            }
            completion(result)
        }
    }
    
    private func isCacheValid(for lon: Double, lat: Double) -> Bool {
        guard let lastFetch = lastFetchTime, let coords = cachedCoord else {
            return false
        }
        
        let isCoordMached = coords.lat == lat && coords.lon == lon
        let isTimeNotExpired = Date().timeIntervalSince(lastFetch) < cacheDuration
        return isCoordMached && isTimeNotExpired
    }
}
