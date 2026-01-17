import UIKit
import Foundation
import CoreData

class FavoritesViewPresenter: FavoritesViewPresenterProtocol {

    

    weak var view: FavoritesViewControllerProtocol?
    let dataCoreManager: FavoritesStorageProtocol
    
    init(view: FavoritesViewControllerProtocol?,
         dataCoreManager: FavoritesStorageProtocol) {
        self.view = view
        self.dataCoreManager = dataCoreManager
    }
    
    func loadSavedWeather() -> [FavoriteCity] {
        let cities = dataCoreManager.fetchAllFavorites()
        return cities
    }
    

}

