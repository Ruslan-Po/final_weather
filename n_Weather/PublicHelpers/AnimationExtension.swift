import UIKit

extension UIImageView {
    func animateTap(scale: CGFloat = 0.85, duration: TimeInterval = 0.3) {
        let shrinkDuration = duration / 3  // 0.1 сек на сжатие
        let expandDuration = duration * 2 / 3  // 0.2 сек на возврат
        
        UIView.animate(
            withDuration: shrinkDuration,
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: expandDuration,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseOut
                ) {
                    self.transform = .identity
                }
            }
        )
    }
}
