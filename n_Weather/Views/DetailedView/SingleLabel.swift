import UIKit

class SingleStack: UIView {
    
    init(imageName: String) {
        super.init(frame: .zero)
        imageView.image = UIImage(named: imageName)
        setupLocalUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.widthAnchor.constraint(equalTo: imageview.heightAnchor).isActive = true
        imageview.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = AppColors.primary
        stackView.layer.cornerRadius = 8
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.ultraLargePadding
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public func config(text: String) {
        label.text = text
    }
    
    func setupLocalUI(){
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
    }
}
