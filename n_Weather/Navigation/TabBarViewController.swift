import UIKit

class TabBarViewController: UITabBarController {
    private let container = AppContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = AppColors.tabColor
        tabBar.tintColor = .white
        tabBar.barTintColor = .gray
        setTabs()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var tabBarFrame = tabBar.frame
        let customHeight: CGFloat = 90
        tabBarFrame.size.height = customHeight
        tabBarFrame.origin.y = view.frame.height - customHeight
        tabBar.frame = tabBarFrame
    }
    
    private func setTabs() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let mainView = MainAssembler.createMainViewController(container: container)
        mainView.tabBarItem = UITabBarItem(
            title: "Weather",
            image: UIImage(systemName: "house", withConfiguration: config),
            selectedImage: UIImage(systemName: "house.fill", withConfiguration: config)
        )
        mainView.tabBarItem.imageInsets = iconInsets
        
        let forecast = ForecastAssembler.createForecastViewController(container: container)
        forecast.tabBarItem = UITabBarItem(
            title: "Forecast",
            image: UIImage(systemName: "calendar", withConfiguration: config),
            selectedImage: UIImage(systemName: "calendar.fill", withConfiguration: config)
        )
        forecast.tabBarItem.imageInsets = iconInsets
        
        let detail = DetailViewAssembler.createDetailedViewController(container: container)
        detail.tabBarItem = UITabBarItem(
            title: "Detail",
            image: UIImage(systemName: "info.circle", withConfiguration: config),
            selectedImage: UIImage(systemName: "info.circle.fill", withConfiguration: config)
        )
        detail.tabBarItem.imageInsets = iconInsets
        
        let favorites = FavoritesAssembler.maskeFavoritesViewController(container: container)
        favorites.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart", withConfiguration: config),
            selectedImage: UIImage(systemName: "heart.fill",withConfiguration: config)
        )
        
        setViewControllers([mainView, forecast, detail,favorites], animated: false)
    }
}


