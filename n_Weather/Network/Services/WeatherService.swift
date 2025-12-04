import Foundation

enum WeatherErrors: Error, Sendable {
    case invalidURL
    case URLconstructionFailed
    case noData
    case decodingFailed
}

protocol WeatherServiceProtocol {
    func fetchWeatherData(longitude: Double,latitude: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void)
}

class WeatherService: WeatherServiceProtocol{
    
     let apiKey: String
     private let session: URLSessionProtocol
     private let decoder: JSONDecoder
     
     init(
         apiKey: String = "7cdd70a88a12f2058c790ed2952ac54a",
         session: URLSessionProtocol = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder()
     ) {
         self.apiKey = apiKey
         self.session = session
         self.decoder = decoder
     }
  
    func createWeatherURL(lon: Double, lat: Double, key: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"
        
        components.queryItems = [
            URLQueryItem (name: "lat",value: String(lat)),
            URLQueryItem (name: "lon",value: String(lon)),
            URLQueryItem (name: "appid",value: key),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components.url
    }
    
    func fetchWeatherData(longitude: Double,latitude: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        Task {
            guard let url = createWeatherURL(lon: longitude, lat: latitude, key: apiKey) else {
                completion(.failure(WeatherErrors.URLconstructionFailed))
                return
            }
            do {
                let (data, _) = try await session.data(from: url)
                do {
                    let weather = try decoder.decode(WeatherModel.self, from: data)
                    completion(.success(weather))
                } catch {
                    completion(.failure(WeatherErrors.decodingFailed))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}



