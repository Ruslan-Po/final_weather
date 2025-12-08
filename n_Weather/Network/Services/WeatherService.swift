import Foundation

enum WeatherErrors: Error, Sendable, LocalizedError {
    case invalidURL
    case URLconstructionFailed
    case noData
    case decodingFailed
    case networkError
    case serverError(Int)
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "incorrect URL"
        case .URLconstructionFailed:
            return "Failed to create URL"
        case .noData:
            return "Data not received"
        case .decodingFailed:
            return "Data processing error"
        case .networkError:
            return "Internet connection issues. Please check your network connection."
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchWeatherData(longitude: Double,
                          latitude: Double,
                          completion: @escaping (Result<WeatherModel, Error>) -> Void)
}

class WeatherService: WeatherServiceProtocol {
    let apiKey: String
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let completionQueue: DispatchQueue
    
    init(
        apiKey: String = "7cdd70a88a12f2058c790ed2952ac54a",
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        completionQueue: DispatchQueue = .main
    ) {
        self.apiKey = apiKey
        self.session = session
        self.decoder = decoder
        self.completionQueue = completionQueue
    }
    func createWeatherURL(lon: Double, lat: Double, key: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components.url
    }
    func fetchWeatherData(longitude: Double,
                          latitude: Double,
                          completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        Task {
            guard let url = createWeatherURL(lon: longitude, lat: latitude, key: apiKey) else {
                completionQueue.async{
                    completion(.failure(WeatherErrors.URLconstructionFailed))
                }
                return
            }
            do {
                let (data, response) = try await session.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    guard (200...299).contains(httpResponse.statusCode) else {
                        completionQueue.async {
                            completion(.failure(WeatherErrors.serverError(httpResponse.statusCode)))
                        }
                        return
                    }
                }
                do {
                    let weather = try decoder.decode(WeatherModel.self, from: data)
                    completionQueue.async {
                        completion(.success(weather))
                    }
                } catch {
                    completionQueue.async {
                        completion(.failure(WeatherErrors.decodingFailed))
                    }
                }
            } catch {
                completionQueue.async {
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                            completion(.failure(WeatherErrors.networkError))
                        default:
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
