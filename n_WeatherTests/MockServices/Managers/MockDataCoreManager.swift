import XCTest
@testable import n_Weather

class MockFavoritesStorage: FavoritesStorageProtocol {

    
    var saveWasCalled = false
    var deleteWasCalled = false
    var fetchWasCalled = false
    var findWasCalled = false
    var isFavoriteWasCalled = false
    var updateFavoriteWasCalled = false
    
    var lastSavedWeatherModel: WeatherModel?
    var lastDeletedCityName: String?
    var lastFindCityName: String?
    var lastIsFavoriteCityName: String?
    var lastUpdateFavoriteCityName: String?
    var lastUpdateFavoriteWeatherModel: WeatherModel?
    
    var citiesToReturn: [FavoriteCity] = []
    var cityToReturn: FavoriteCity?
    var isFavoriteResult: Bool = false
    
    func saveFavoriteCity(from weatherModel: WeatherModel) {
        saveWasCalled = true
        lastSavedWeatherModel = weatherModel
    }
    
    func deleteFavoriteCity(cityName: String) {
        deleteWasCalled = true
        lastDeletedCityName = cityName
    }
    
    func fetchAllFavoriteCities() -> [FavoriteCity] {
        fetchWasCalled = true
        return citiesToReturn
    }
    
    func findCity(byName name: String) -> FavoriteCity? {
        findWasCalled = true
        lastFindCityName = name
        return cityToReturn
    }
    
    func isFavorite(cityName: String) -> Bool {
        isFavoriteWasCalled = true
        lastIsFavoriteCityName = cityName
        return isFavoriteResult
    }
    
    func updateFavorite(cityName: String, with weatherModel: WeatherModel) {
        updateFavoriteWasCalled = true
        lastUpdateFavoriteCityName = cityName
        lastUpdateFavoriteWeatherModel = weatherModel
    }
    
    func fetchAllFavorites() -> [FavoriteCity] {
        return []
    }
    
    func findCity(byCoordinates lat: Double, lon: Double) -> FavoriteCity? {
        return nil
    }
    
    func deleteFavorite(_ city: FavoriteCity) {
        
    }
    
    func deleteFavorite(byName cityName: String) {
        
    }
    
    func saveContext() {
        
    }
}

