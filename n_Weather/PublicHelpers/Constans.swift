import UIKit

enum Layout {
    static let extraSmallPadding: CGFloat = 5
    static let smallPadding: CGFloat = 10
    static let mediumPadding: CGFloat = 15
    static let largePadding: CGFloat = 20
    static let extraLargePadding: CGFloat = 30
    static let ultraLargePadding: CGFloat = 90
    
    static let cornerRadius: CGFloat = 8
    static let constansHeight: CGFloat = 44
    static let constansWidth: CGFloat = 44
    
    enum Spacing {
        static let minimal: CGFloat = 5
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

enum AppFonts {
    static func title(size: CGFloat = 30) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }
    
    static func body(size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }
    
    static func caption(size: CGFloat = 12) -> UIFont {
        .systemFont(ofSize: size, weight: .light)
    }
}

enum AppColors {
    static let primary = UIColor.systemGray6
    static let secondary = UIColor.systemGray
    static let background = UIColor.systemGray2
    static let tabColor = UIColor.systemGray3
    static let tint = UIColor.gray
}


enum CellIdentifiers {
    static let forecastCell = "ForecastTableViewCell"
}
