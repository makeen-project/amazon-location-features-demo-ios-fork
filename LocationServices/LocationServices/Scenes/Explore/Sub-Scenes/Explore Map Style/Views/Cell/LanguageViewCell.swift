import UIKit

class LanguageViewCell: UITableViewCell {
    private let containerView: UIView = UIView()
    private let contentCellView: UIView = UIView()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        label.text = "Language"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(contentCellView)
        contentCellView.addSubview(itemTitle)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentCellView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        itemTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    func configure(with languageSwitcherData: LanguageSwitcherData) {
        itemTitle.text = languageSwitcherData.label
    }
}
