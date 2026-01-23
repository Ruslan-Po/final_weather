import CoreData
@testable import n_Weather

extension FavoriteCity {
    static func mock(
        in context: NSManagedObjectContext,
        cityName: String = "Moscow",
        latitude: Double = 55.7558,
        longitude: Double = 37.6173,
        sunrise: Int64 = 1704081600,
        sunset: Int64 = 1704117600
    ) -> FavoriteCity {
        let city = FavoriteCity(context: context)
        city.cityName = cityName
        city.latitude = latitude
        city.longitude = longitude
        city.sunrise = sunrise
        city.sunset = sunset
        city.cachedAt = Date()
        return city
    }
}


extension CachedWeather {
    static func mock(
        in context: NSManagedObjectContext,
        temperature: Double = 20.5,
        windSpeed: Double = 5.5,
        windDeg: Int16 = 180,
        windGust: Double = 8.0,
        feelsLike: Double = 18.5,
        tempMax: Double = 25.0,
        tempMin: Double = 15.0,
        humidity: Int16 = 65,
        pressure: Int16 = 1013,
        visibility: Int32 = 10000,
        dateTime: Int64 = 1704067200
    ) -> CachedWeather {
        let weather = CachedWeather(context: context)
        weather.temperature = temperature
        weather.windSpeed = windSpeed
        weather.windDeg = windDeg
        weather.windGust = windGust
        weather.feelsLike = feelsLike
        weather.tempMax = tempMax
        weather.tempMin = tempMin
        weather.humidity = humidity
        weather.pressure = pressure
        weather.visibility = visibility
        weather.dateTime = dateTime
        return weather
    }
}
