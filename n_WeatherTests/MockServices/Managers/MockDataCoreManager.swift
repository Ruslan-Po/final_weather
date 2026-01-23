import XCTest
import CoreData
@testable import n_Weather

class MockFavoritesStorage: FavoritesStorageProtocol {

    var saveFavoriteCityWasCalled = false
    var findCityWasCalled = false
    var checkIsFavoriteWasCalled = false
    var updateFavoriteWasCalled = false
    var fetchWasCalled = false
    var findByCoordinatesWasCalled = false
    var deleteFavoriteObjectWasCalled = false
    var deleteFavoriteCityWasCalled = false
    var saveContextWasCalled = false
    var deleteCallCount = 0
    
    var lastSavedWeatherModel: WeatherModel?
    var lastDeletedCityName: String?
    var lastFindCityName: String?
    var lastIsFavoriteCityName: String?
    var lastUpdateFavoriteCityName: String?
    var lastUpdateFavoriteWeatherModel: WeatherModel?
    var lastDeletedCity: FavoriteCity?
    var lastFindCoordinatesLat: Double?
    var lastFindCoordinatesLon: Double?
    
    var citiesToReturn: [FavoriteCity] = []
    var cityToReturn: FavoriteCity?
    var cityByCoordinatesToReturn: FavoriteCity?
    var isFavoriteResult: Bool = false
    
    func saveFavoriteCity(from weatherModel: WeatherModel) {
        saveFavoriteCityWasCalled = true
        lastSavedWeatherModel = weatherModel
    }
    
    func findCity(byName name: String) -> FavoriteCity? {
        findCityWasCalled = true
        lastFindCityName = name
        return cityToReturn
    }
    
    func isFavorite(cityName: String) -> Bool {
        checkIsFavoriteWasCalled = true
        lastIsFavoriteCityName = cityName
        return isFavoriteResult
    }
    
    func updateFavorite(cityName: String, with weatherModel: WeatherModel) {
        updateFavoriteWasCalled = true
        lastUpdateFavoriteCityName = cityName
        lastUpdateFavoriteWeatherModel = weatherModel
    }
    
    func fetchAllFavorites() -> [FavoriteCity] {
        fetchWasCalled = true
        return citiesToReturn
    }
    
    func findCity(byCoordinates lat: Double, lon: Double) -> FavoriteCity? {
        findByCoordinatesWasCalled = true
        lastFindCoordinatesLat = lat
        lastFindCoordinatesLon = lon
        return cityByCoordinatesToReturn
    }
    
    func deleteFavorite(_ city: FavoriteCity) {
        deleteFavoriteObjectWasCalled = true
        lastDeletedCity = city
        deleteCallCount += 1
    }
    
    func deleteFavoriteByCityName(byName cityName: String) {
        deleteFavoriteCityWasCalled = true
        lastDeletedCityName = cityName
        deleteCallCount += 1
    }
    
    func saveContext() {
        saveContextWasCalled = true
    }
}
