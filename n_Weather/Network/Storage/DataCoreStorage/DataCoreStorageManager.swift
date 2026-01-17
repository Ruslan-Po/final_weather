import Foundation
import CoreData

class DataCoreStorageManager: FavoritesStorageProtocol {
    
    private init() {}
    static let shared = DataCoreStorageManager()
    
    // MARK: - Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "n_Weather")
        container.loadPersistentStores {_, error in
            if let error = error as NSError? {
                fatalError("Core Data load error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Create
    
    func saveFavoriteCity(from weatherModel: WeatherModel) {
        if let existingCity = findCity(byName: weatherModel.city.name) {
            updateForecast(for: existingCity, with: weatherModel)
            return
        }
        
        let city = FavoriteCity(context: context)
        city.cityName = weatherModel.city.name
        city.latitude = weatherModel.city.coord.lat
        city.longitude = weatherModel.city.coord.lon
        city.sunrise = Int64(weatherModel.city.sunrise)
        city.sunset = Int64(weatherModel.city.sunset)
        city.cachedAt = Date()
        
        for forecastData in weatherModel.list {
            let forecast = createCachedWeather(from: forecastData)
            forecast.city = city
        }
        
        saveContext()
    }
    
    private func createCachedWeather(from data: Forecast) -> CachedWeather {
        let cachedWeather = CachedWeather(context: context)
        
        cachedWeather.datetime = Int64(data.datetime)
        cachedWeather.dateString = data.date
        cachedWeather.temperature = data.main.temp
        cachedWeather.tempMin = data.main.tempMin
        cachedWeather.tempMax = data.main.tempMax
        cachedWeather.feelsLike = data.main.feelsLike
        cachedWeather.humidity = Int16(data.main.humidity)
        cachedWeather.pressure = Int16(data.main.pressure)
        cachedWeather.windSpeed = data.wind.speed
        cachedWeather.windDeg = Int16(data.wind.deg)
        cachedWeather.visibility = Int32(data.visibility ?? 0)
        cachedWeather.windGust = data.wind.gust ?? 0
        
        if let weather = data.weather.first {
            cachedWeather.weatherCondition = weather.main
            cachedWeather.weatherDescription = weather.description
            cachedWeather.weatherId = Int16(weather.id)
        }
        
        return cachedWeather
    }
    
    // MARK: - Read
    
    func fetchAllFavorites() -> [FavoriteCity] {
        let request = FavoriteCity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func findCity(byName name: String) -> FavoriteCity? {
        let request = FavoriteCity.fetchRequest()
        request.predicate = NSPredicate(format: "cityName == %@", name)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    func findCity(byCoordinates lat: Double, lon: Double) -> FavoriteCity? {
        let request = FavoriteCity.fetchRequest()
        request.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", lat, lon)
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
    
    // MARK: - Update
    
    private func updateForecast(for city: FavoriteCity, with weatherModel: WeatherModel) {
        if let oldForecasts = city.forecast as? Set<CachedWeather> {
            oldForecasts.forEach { context.delete($0) }
        }
        
        city.sunrise = Int64(weatherModel.city.sunrise)
        city.sunset = Int64(weatherModel.city.sunset)
        city.cachedAt = Date()
        
        for forecastData in weatherModel.list {
            let forecast = createCachedWeather(from: forecastData)
            forecast.city = city
        }
        
        saveContext()
    }
    
    func updateFavorite(cityName: String, with weatherModel: WeatherModel) {
        guard let city = findCity(byName: cityName) else { return }
        updateForecast(for: city, with: weatherModel)
    }
    
    // MARK: - Delete
    
    func deleteFavorite(_ city: FavoriteCity) {
        context.delete(city)
        saveContext()
    }
    
    func deleteFavorite(byName cityName: String) {
        guard let city = findCity(byName: cityName) else { return }
        deleteFavorite(city)
    }
    
    func deleteAllFavorites() {
        let cities = fetchAllFavorites()
        cities.forEach { context.delete($0) }
        saveContext()
    }
    
    // MARK: - Check
    
    func isFavorite(cityName: String) -> Bool {
        return findCity(byName: cityName) != nil
    }
}
