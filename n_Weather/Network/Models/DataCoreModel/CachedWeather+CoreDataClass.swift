//
//  CachedWeather+CoreDataClass.swift
//  n_Weather
//
//  Created by Ruslan Popovich on 03/01/2026.
//
//

public import Foundation
public import CoreData

public typealias CachedWeatherCoreDataClassSet = NSSet

@objc(CachedWeather)
public class CachedWeather: NSManagedObject {

}

public typealias CachedWeatherCoreDataPropertiesSet = NSSet

extension CachedWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedWeather> {
        return NSFetchRequest<CachedWeather>(entityName: "CachedWeather")
    }

    @NSManaged public var dateString: String?
    @NSManaged public var datetime: Int64
    @NSManaged public var feelsLike: Double
    @NSManaged public var humidity: Int16
    @NSManaged public var pressure: Int16
    @NSManaged public var temperature: Double
    @NSManaged public var tempMax: Double
    @NSManaged public var tempMin: Double
    @NSManaged public var visibility: Int32
    @NSManaged public var weatherCondition: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var weatherId: Int16
    @NSManaged public var windDeg: Int16
    @NSManaged public var windGust: Double
    @NSManaged public var windSpeed: Double
    @NSManaged public var city: FavoriteCity?

}

extension CachedWeather: Identifiable {

}
