
public import Foundation
public import CoreData

public typealias FavoriteCityCoreDataClassSet = NSSet

@objc(FavoriteCity)
public class FavoriteCity: NSManagedObject {

}

public typealias FavoriteCityCoreDataPropertiesSet = NSSet

extension FavoriteCity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCity> {
        return NSFetchRequest<FavoriteCity>(entityName: "FavoriteCity")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var sunrise: Int64
    @NSManaged public var sunset: Int64
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var cachedAt: Date?
    @NSManaged public var forecast: NSSet?

}

// MARK: Generated accessors for forecast
extension FavoriteCity {

    @objc(addForecastObject:)
    @NSManaged public func addToForecast(_ value: CachedWeather)

    @objc(removeForecastObject:)
    @NSManaged public func removeFromForecast(_ value: CachedWeather)

    @objc(addForecast:)
    @NSManaged public func addToForecast(_ values: NSSet)

    @objc(removeForecast:)
    @NSManaged public func removeFromForecast(_ values: NSSet)

}

extension FavoriteCity: Identifiable {

}

extension FavoriteCity {
    
    var forecastArray: [CachedWeather] {
        let set = forecast as? Set<CachedWeather> ?? []
        return set.sorted { $0.datetime < $1.datetime }
    }
    var currentWeather: CachedWeather? {
        return forecastArray.first
    }
}

