import UIKit

final class DetailViewAssembler {
    static func createDetailedViewController(container: AppContainer) -> UIViewController {
        let view = DetailViewController()
        
        let presenter =  DetailedViewPresenter(view: view,
                                               repository: container.weatherRepository, locationStorage: container.storage
            
        )
        
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        
        return navigationController
    }
}

